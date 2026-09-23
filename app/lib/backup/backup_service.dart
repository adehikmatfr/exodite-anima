import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:cryptography/dart.dart' show DartSha256;

import '../data/entry_repository.dart';
import '../data/journal_database.dart' show journalSchemaVersion;
import 'envelope.dart';
import 'zip_lite.dart';

/// The export and import format (ADR-003, `formatVersion` 1).
///
/// ```
/// manifest.json        format, formatVersion, schemaVersion, appVersion, createdAt, entryCount, entriesSha256
/// entries.json         the entries: the ONLY file the importer reads for content
/// entries/YYYY/YYYY-MM-DD-<id>.md   one readable file per entry (plaintext exports only)
/// media/<id>.<ext>     one file per photo (FEAT-011), its plaintext bytes; named by entries.json's own `media[].path`
/// ```
const backupFormatName = 'exodite-anima-journal';
const currentFormatVersion = 1;
const appVersionText = '1.1.0';

/// What an import accepts. PROVISIONAL: the owner has not decided the numeric
/// import limits (TC-065); these are set from the spike and can be changed here.
class ImportLimits {
  const ImportLimits({
    this.zip = const ZipLimits(),
    this.maxEntries = 100000,
    this.maxEntryBytes = 1024 * 1024,
  });
  final ZipLimits zip;
  final int maxEntries;
  final int maxEntryBytes;
}

enum BackupProblem {
  /// The file is not one of ours, or is cut off or damaged.
  damaged,

  /// The file is encrypted and no password was given.
  needsPassword,

  /// Wrong password, or the file was changed. The two cannot be told apart.
  wrongPasswordOrChanged,

  /// Made by a newer version of the app than this one can read.
  tooNew,

  /// Over a size or count limit.
  tooLarge,
}

class BackupException implements Exception {
  BackupException(this.problem, [this.detail = '']);
  final BackupProblem problem;
  final String detail;
  @override
  String toString() => 'BackupException: $problem $detail';
}

class ReadBackup {
  ReadBackup(this.entries, this.formatVersion, this.createdAt, {this.mediaBytes = const {}});
  final List<StoredEntry> entries;
  final int formatVersion;
  final DateTime? createdAt;

  /// Each imported photo's plaintext bytes, by [StoredMediaRef.uid]
  /// (FEAT-011). The importer hands this straight to
  /// `EntryRepository.importEntries`, which re-encrypts them under the
  /// device's own key - a photo is never carried across in its export form.
  final Map<String, Uint8List> mediaBytes;
}

/// `media/<id>.<ext>`'s extension, from the photo's own `mimeType` (FEAT-011,
/// ADR-003 update 2026-09-23) - readable outside the app, unlike a bare id.
/// Every mime type [MediaFiles]/`image_picker` can produce has one; anything
/// else falls back to `bin` rather than refusing the whole export.
String _extensionFor(String mimeType) => switch (mimeType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/heic' => 'heic',
      'image/webp' => 'webp',
      _ => 'bin',
    };

const _mimeForExtension = {
  'jpg': 'image/jpeg',
  'png': 'image/png',
  'heic': 'image/heic',
  'webp': 'image/webp',
  'bin': 'application/octet-stream',
};

final _mediaPathPattern = RegExp(r'^media/([0-9a-f]{32})\.(jpg|png|heic|webp|bin)$');

/// Builds the file to hand to the share sheet. [password] null means a
/// plaintext export. [photoBytes] holds each photo's plaintext bytes, by
/// [StoredMediaRef.uid] (FEAT-011); a photo whose entry references it but
/// that is missing here (its file could not be decrypted, AC-8) is left out
/// of the archive entirely, rather than failing the whole export.
Future<Uint8List> createBackup(
  List<StoredEntry> entries, {
  String? password,
  DateTime? now,
  EnvelopeParams? params,
  Map<String, Uint8List> photoBytes = const {},
}) async {
  final zip = await Isolate.run(() => _buildZip(entries, plaintext: password == null, now: now ?? DateTime.now(), photoBytes: photoBytes));
  if (password == null) return zip;
  return encryptBackup(zip, password, params: params);
}

Uint8List _buildZip(List<StoredEntry> entries, {required bool plaintext, required DateTime now, required Map<String, Uint8List> photoBytes}) {
  final entriesJson = Uint8List.fromList(utf8.encode(jsonEncode({
    'formatVersion': currentFormatVersion,
    'schemaVersion': journalSchemaVersion,
    'entries': [
      for (final e in entries)
        {
          'id': e.uid,
          'entryDate': e.day,
          'createdAt': DateTime.fromMillisecondsSinceEpoch(e.createdAtMs, isUtc: true).toIso8601String(),
          'updatedAt': DateTime.fromMillisecondsSinceEpoch(e.updatedAtMs, isUtc: true).toIso8601String(),
          'text': e.text,
          // Additive fields (ADR-003 update 2026-09-23, FEAT-010 AC-7): an
          // older app ignores them (rule 2); absent, not null, when unset,
          // so an export made before FEAT-010 looks the same as one with no
          // mood or tags on any entry.
          if (e.mood != null) 'mood': e.mood!.name,
          if (e.tags.isNotEmpty) 'tags': e.tags,
          if (e.media.any((m) => photoBytes.containsKey(m.uid)))
            'media': [
              for (final m in e.media)
                if (photoBytes.containsKey(m.uid))
                  {
                    'id': m.uid,
                    'path': 'media/${m.uid}.${_extensionFor(m.mimeType)}',
                    if (m.caption != null) 'caption': m.caption,
                  },
            ],
        },
    ],
  })));
  final manifest = Uint8List.fromList(utf8.encode(jsonEncode({
    'format': backupFormatName,
    'formatVersion': currentFormatVersion,
    'schemaVersion': journalSchemaVersion,
    'appVersion': appVersionText,
    'createdAt': now.toUtc().toIso8601String(),
    'entryCount': entries.length,
    'entriesSha256': sha256Hex(entriesJson),
  })));
  final files = <ZipEntry>[ZipEntry('manifest.json', manifest), ZipEntry('entries.json', entriesJson)];
  if (plaintext) {
    // A classic ZIP index holds 65,535 names; two are taken.
    if (entries.length > 65000) throw BackupException(BackupProblem.tooLarge, 'too many entries for a plaintext export');
    for (final e in entries) {
      final year = e.day.substring(0, 4);
      files.add(ZipEntry('entries/$year/${e.day}-${e.uid}.md', Uint8List.fromList(utf8.encode(_markdown(e)))));
    }
  }
  for (final e in entries) {
    for (final m in e.media) {
      final bytes = photoBytes[m.uid];
      if (bytes == null) continue;
      files.add(ZipEntry('media/${m.uid}.${_extensionFor(m.mimeType)}', bytes));
    }
  }
  return writeZip(files);
}

String _markdown(StoredEntry e) {
  final meta = StringBuffer();
  if (e.mood != null) meta.write('Mood: ${e.mood!.name}\n');
  if (e.tags.isNotEmpty) meta.write('Tags: ${e.tags.join(', ')}\n');
  return '# ${e.day}\n\n$meta\n${e.text}\n';
}

/// A `mood` field this app does not recognise (an older name, or one from a
/// future version) is dropped rather than refusing the whole import: rule 2,
/// unknown values inside a known format are ignored.
Mood? _moodFromJson(Object? value) {
  if (value is! String) return null;
  for (final m in Mood.values) {
    if (m.name == value) return m;
  }
  return null;
}

List<String> _tagsFromJson(Object? value) {
  if (value is! List) return const [];
  return [for (final t in value) if (t is String && t.trim().isNotEmpty) t];
}

String sha256Hex(List<int> bytes) {
  final hash = const DartSha256().hashSync(bytes);
  return hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// Reads and checks a backup file, and returns its entries. Nothing is applied
/// here: the caller adds them to the journal in one transaction.
Future<ReadBackup> readBackup(Uint8List file, {String? password, ImportLimits limits = const ImportLimits()}) async {
  if (file.length > limits.zip.maxFileBytes) throw BackupException(BackupProblem.tooLarge, 'file');
  Uint8List zip = file;
  if (isEncryptedBackup(file)) {
    if (password == null) throw BackupException(BackupProblem.needsPassword);
    try {
      zip = await decryptBackup(file, password);
    } on EnvelopeException catch (e) {
      throw switch (e.problem) {
        EnvelopeProblem.unsupported => BackupException(BackupProblem.tooNew, 'envelope'),
        _ => BackupException(BackupProblem.wrongPasswordOrChanged),
      };
    }
  }
  return Isolate.run(() => _parse(zip, limits));
}

ReadBackup _parse(Uint8List zip, ImportLimits limits) {
  Map<String, Uint8List> readNamed(Set<String> names) {
    try {
      return readZipFiles(zip, names, limits: limits.zip);
    } on ZipException catch (e) {
      final large = e.message.contains('limit') || e.message.contains('too large') || e.message.contains('too many');
      throw BackupException(large ? BackupProblem.tooLarge : BackupProblem.damaged, e.message);
    }
  }

  final files = readNamed({'manifest.json', 'entries.json'});
  final manifestBytes = files['manifest.json'];
  final entriesBytes = files['entries.json'];
  if (manifestBytes == null || entriesBytes == null) throw BackupException(BackupProblem.damaged, 'missing file');

  final Map<String, dynamic> manifest;
  try {
    manifest = jsonDecode(utf8.decode(manifestBytes)) as Map<String, dynamic>;
  } catch (_) {
    throw BackupException(BackupProblem.damaged, 'manifest');
  }
  if (manifest['format'] != backupFormatName) throw BackupException(BackupProblem.damaged, 'not a journal export');
  final version = manifest['formatVersion'];
  if (version is! int || version < 1) throw BackupException(BackupProblem.damaged, 'version');
  // Every older formatVersion must stay importable; add a reader per version here.
  if (version > currentFormatVersion) throw BackupException(BackupProblem.tooNew, 'formatVersion $version');
  if (manifest['entriesSha256'] != sha256Hex(entriesBytes)) {
    throw BackupException(BackupProblem.damaged, 'entries do not match the manifest');
  }

  final Map<String, dynamic> doc;
  try {
    doc = jsonDecode(utf8.decode(entriesBytes)) as Map<String, dynamic>;
  } catch (_) {
    throw BackupException(BackupProblem.damaged, 'entries');
  }
  final list = doc['entries'];
  if (list is! List) throw BackupException(BackupProblem.damaged, 'entries');
  if (list.length > limits.maxEntries) throw BackupException(BackupProblem.tooLarge, 'entries');
  if (manifest['entryCount'] != list.length) throw BackupException(BackupProblem.damaged, 'entry count');

  final seen = <String>{};
  final entries = <StoredEntry>[];
  final wantedMediaPaths = <String>{};
  final idPattern = RegExp(r'^[0-9a-f]{32}$');
  final dayPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  for (final raw in list) {
    if (raw is! Map<String, dynamic>) throw BackupException(BackupProblem.damaged, 'entry');
    final id = raw['id'];
    final day = raw['entryDate'];
    final text = raw['text'];
    if (id is! String || !idPattern.hasMatch(id)) throw BackupException(BackupProblem.damaged, 'entry id');
    if (day is! String || !dayPattern.hasMatch(day) || DateTime.tryParse(day) == null) {
      throw BackupException(BackupProblem.damaged, 'entry date');
    }
    if (text is! String) throw BackupException(BackupProblem.damaged, 'entry text');
    if (utf8.encode(text).length > limits.maxEntryBytes) throw BackupException(BackupProblem.tooLarge, 'entry size');
    if (!seen.add(id)) throw BackupException(BackupProblem.damaged, 'duplicate id');
    final created = DateTime.tryParse('${raw['createdAt']}');
    final updated = DateTime.tryParse('${raw['updatedAt']}');
    if (created == null || updated == null) throw BackupException(BackupProblem.damaged, 'entry time');
    entries.add(StoredEntry(
      uid: id,
      day: day,
      text: text,
      createdAtMs: created.millisecondsSinceEpoch,
      updatedAtMs: updated.millisecondsSinceEpoch,
      mood: _moodFromJson(raw['mood']),
      tags: _tagsFromJson(raw['tags']),
      media: _mediaFromJson(raw['media'], wantedMediaPaths),
    ));
  }

  // A second, exact-name pass: only now, having validated every path inside
  // entries.json, do we know which `media/` files to open at all (rule 3:
  // never anything else, never guessed from the archive's own listing).
  final mediaFiles = wantedMediaPaths.isEmpty ? const <String, Uint8List>{} : readNamed(wantedMediaPaths);
  final mediaBytes = <String, Uint8List>{};
  for (final entry in entries) {
    for (final ref in entry.media) {
      final path = 'media/${ref.uid}.${_extensionFor(ref.mimeType)}';
      final bytes = mediaFiles[path];
      if (bytes != null) mediaBytes[ref.uid] = bytes;
    }
  }
  return ReadBackup(entries, version, DateTime.tryParse('${manifest['createdAt']}'), mediaBytes: mediaBytes);
}

/// Parses an entry's `media` field (FEAT-011, ADR-003 update 2026-09-23):
/// each photo's `id`, `path`, and optional `caption`. A malformed photo
/// entry is dropped, not a whole-import failure - rule 2's "ignore what is
/// not understood" extended to a single bad photo reference. Every accepted
/// path is added to [wantedPaths], the exact-name set the second ZIP pass
/// reads (rule 3: nothing else is ever opened).
List<StoredMediaRef> _mediaFromJson(Object? value, Set<String> wantedPaths) {
  if (value is! List) return const [];
  final idPattern = RegExp(r'^[0-9a-f]{32}$');
  final refs = <StoredMediaRef>[];
  for (final raw in value) {
    if (raw is! Map<String, dynamic>) continue;
    final id = raw['id'];
    final path = raw['path'];
    final caption = raw['caption'];
    if (id is! String || !idPattern.hasMatch(id)) continue;
    if (path is! String) continue;
    final match = _mediaPathPattern.firstMatch(path);
    if (match == null || match.group(1) != id) continue;
    if (caption != null && caption is! String) continue;
    wantedPaths.add(path);
    refs.add(StoredMediaRef(uid: id, mimeType: _mimeForExtension[match.group(2)]!, caption: caption as String?));
  }
  return refs;
}
