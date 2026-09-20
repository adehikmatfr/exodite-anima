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
/// ```
const backupFormatName = 'exodite-anima-journal';
const currentFormatVersion = 1;
const appVersionText = '1.0.0';

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
  ReadBackup(this.entries, this.formatVersion, this.createdAt);
  final List<StoredEntry> entries;
  final int formatVersion;
  final DateTime? createdAt;
}

/// Builds the file to hand to the share sheet. [password] null means a plaintext export.
Future<Uint8List> createBackup(List<StoredEntry> entries, {String? password, DateTime? now, EnvelopeParams? params}) async {
  final zip = await Isolate.run(() => _buildZip(entries, plaintext: password == null, now: now ?? DateTime.now()));
  if (password == null) return zip;
  return encryptBackup(zip, password, params: params);
}

Uint8List _buildZip(List<StoredEntry> entries, {required bool plaintext, required DateTime now}) {
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
  return writeZip(files);
}

String _markdown(StoredEntry e) => '# ${e.day}\n\n${e.text}\n';

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
  final Map<String, Uint8List> files;
  try {
    files = readZipFiles(zip, {'manifest.json', 'entries.json'}, limits: limits.zip);
  } on ZipException catch (e) {
    final large = e.message.contains('limit') || e.message.contains('too large') || e.message.contains('too many');
    throw BackupException(large ? BackupProblem.tooLarge : BackupProblem.damaged, e.message);
  }
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
    ));
  }
  return ReadBackup(entries, version, DateTime.tryParse('${manifest['createdAt']}'));
}
