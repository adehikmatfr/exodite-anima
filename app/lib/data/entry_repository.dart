import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';

import '../backup/reminder.dart';
import 'journal_database.dart';
import 'media_files.dart';

/// The fixed 5-point mood scale (FEAT-010, owner decision 2026-09-23). Order
/// matters: it is this list's index that is stored in the database, so
/// entries never change position once shipped.
enum Mood {
  great,
  good,
  okay,
  bad,
  awful;

  static Mood? fromIndex(int? i) => i == null ? null : Mood.values[i];
}

/// The preset tag list (FEAT-010, product-manager proposal accepted by the
/// owner 2026-09-23). These are shortcuts the editor offers; free text is
/// always allowed too, and storage does not tell the two apart. Fixed
/// English identifiers: `strings.dart` translates them for display, but the
/// stored and exported value is always one of these exact strings.
const List<String> presetTags = ['Work', 'Family', 'Relationships', 'Health', 'Travel', 'Gratitude', 'Goals', 'Reflection'];

/// A photo attached to an entry (FEAT-011), as the rest of the app sees it.
/// The bytes are not here: they are read separately, on demand, since a
/// timeline or editor screen needs the metadata far more often than the
/// (much larger) decrypted bytes themselves.
class StoredPhoto {
  const StoredPhoto({
    required this.uid,
    required this.entryId,
    required this.caption,
    required this.mimeType,
    required this.byteSize,
    required this.sha256,
    required this.createdAtMs,
  });
  final String uid;
  final int entryId;
  final String? caption;
  final String mimeType;
  final int byteSize;
  final String sha256;
  final int createdAtMs;
}

/// A saved entry as the rest of the app sees it.
class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.uid,
    required this.day,
    required this.body,
    this.mood,
    this.tags = const [],
  });
  final int id;
  final String uid; // stable identifier used in exports
  final String day; // yyyy-MM-dd
  final String body;
  final Mood? mood;
  final List<String> tags;
}

/// One row of the timeline: enough to draw the list without loading whole entries.
class TimelineItem {
  const TimelineItem({
    required this.id,
    required this.day,
    required this.createdAtMs,
    required this.preview,
    this.mood,
    this.tags = const [],
  });
  final int id;
  final String day; // yyyy-MM-dd
  final int createdAtMs;
  final String preview; // the first characters of the text
  final Mood? mood;
  final List<String> tags;
}

/// Splits `GROUP_CONCAT(name, char(1))`'s output back into names. `\u0001`
/// cannot appear in a typed tag (same control-character technique as
/// [SearchHit]'s highlight markers), so a tag containing a comma is never
/// split wrongly.
List<String> _splitTags(String? groupConcat) =>
    groupConcat == null || groupConcat.isEmpty ? const [] : groupConcat.split('\u0001');

/// A photo's place in an export and an import: metadata only, the same
/// split [StoredPhoto] makes, since the archive's own reader
/// (`app/lib/backup/backup_service.dart`) fetches bytes from the ZIP
/// separately, keyed by [uid], never through the repository.
class StoredMediaRef {
  const StoredMediaRef({required this.uid, required this.mimeType, this.caption});
  final String uid;
  final String mimeType;
  final String? caption;
}

/// An entry as it travels in an export and an import. `mood` and `tags` are
/// additive fields (ADR-003 update 2026-09-23): an older archive simply has
/// none, and an older app reading a new archive ignores them. `media` is
/// the same, added for FEAT-011.
class StoredEntry {
  const StoredEntry({
    required this.uid,
    required this.day,
    required this.text,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.mood,
    this.tags = const [],
    this.media = const [],
  });
  final String uid;
  final String day; // yyyy-MM-dd
  final String text;
  final int createdAtMs;
  final int updatedAtMs;
  final Mood? mood;
  final List<String> tags;
  final List<StoredMediaRef> media;
}

class ImportOutcome {
  const ImportOutcome({required this.added, required this.skipped});
  final int added;
  final int skipped;
}

/// One search result: the entry, and a short piece of its text in which the
/// matched words are wrapped in [highlightStart] and [highlightEnd].
class SearchHit {
  const SearchHit({required this.id, required this.day, required this.createdAtMs, required this.snippet});
  final int id;
  final String day;
  final int createdAtMs;
  final String snippet;

  static const highlightStart = '\u0001';
  static const highlightEnd = '\u0002';

  /// The snippet split into pieces; `true` marks a matched piece.
  List<(String, bool)> get pieces {
    final out = <(String, bool)>[];
    var matched = false;
    final buf = StringBuffer();
    for (final rune in snippet.runes) {
      final ch = String.fromCharCode(rune);
      if (ch == highlightStart || ch == highlightEnd) {
        if (buf.isNotEmpty) out.add((buf.toString(), matched));
        buf.clear();
        matched = ch == highlightStart;
      } else {
        buf.write(ch);
      }
    }
    if (buf.isNotEmpty) out.add((buf.toString(), matched));
    return out;
  }

  /// The first matched word, for the "matched: ..." note.
  String? get firstMatch {
    for (final (text, matched) in pieces) {
      if (matched) return text;
    }
    return null;
  }
}

/// Turns what the user typed into a full-text query, or null when there is nothing to search for.
///
/// Every word is matched from its START (`riv` finds river, `iver` does not) and
/// all words must match. Punctuation is dropped, so nothing the user types can
/// change the meaning of the query.
String? searchQueryFor(String input) {
  final words = input.split(RegExp(r'[^\p{L}\p{N}]+', unicode: true)).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return null;
  return words.map((w) => '"$w"*').join(' ');
}

/// Unsaved text kept while the user types (FEAT-001 AC-4).
class EntryDraft {
  const EntryDraft({required this.entryId, required this.day, required this.body});
  final int? entryId; // null: a new entry
  final String day;
  final String body;
}

/// Entry storage rules of FEAT-001. Every write is one transaction, so an
/// interruption never leaves half an entry (THR-010, ADR-002).
class EntryRepository {
  EntryRepository(this._db, {int Function()? nowMs, Directory? mediaDirectory, Uint8List? dataKey})
      : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch),
        _media = (mediaDirectory != null && dataKey != null) ? MediaFiles(mediaDirectory, dataKey) : null;

  final JournalDatabase _db;
  final int Function() _nowMs;

  /// Null when no media directory and data key were given - every method
  /// below that touches a photo's bytes needs this; the ones that only touch
  /// the entry's text, mood, or tags never do, so existing callers that have
  /// no reason to handle photos are unaffected.
  final MediaFiles? _media;

  static bool isBlank(String body) => body.trim().isEmpty;

  /// 128 random bits as 32 hex characters.
  static String newEntryUid() {
    final rng = Random.secure();
    return List.generate(16, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  /// Saves a new entry. Returns null and stores nothing when the text is empty
  /// (AC-8). `mood` and `tags` are optional (FEAT-010 AC-1, AC-3).
  Future<JournalEntry?> create({
    required String day,
    required String body,
    Mood? mood,
    List<String> tags = const [],
  }) async {
    if (isBlank(body)) return null;
    return _db.transaction(() async {
      final now = _nowMs();
      final uid = newEntryUid();
      final id = await _db.into(_db.entries).insert(EntriesCompanion.insert(
            uid: uid,
            day: day,
            body: body,
            createdAtMs: now,
            updatedAtMs: now,
            mood: Value(mood?.index),
          ));
      final saved = await _setTags(id, tags);
      await _clearDraft();
      return JournalEntry(id: id, uid: uid, day: day, body: body, mood: mood, tags: saved);
    });
  }

  /// Changes text, date, mood and tags of an entry (AC-2, AC-4, AC-5). False
  /// when the text is empty or the entry does not exist; nothing is changed
  /// then. `mood` and `tags` replace whatever the entry had before, the same
  /// way `body` replaces the old text: the caller always passes the full,
  /// current state, including a cleared mood (`null`) or an empty tag list.
  Future<bool> update({
    required int id,
    required String day,
    required String body,
    Mood? mood,
    List<String> tags = const [],
  }) async {
    if (isBlank(body)) return false;
    return _db.transaction(() async {
      final changed = await (_db.update(_db.entries)..where((e) => e.id.equals(id))).write(
        EntriesCompanion(day: Value(day), body: Value(body), updatedAtMs: Value(_nowMs()), mood: Value(mood?.index)),
      );
      if (changed == 0) return false;
      await _setTags(id, tags);
      await _clearDraft();
      return true;
    });
  }

  /// Replaces an entry's tags with exactly [tags] (trimmed, blanks dropped,
  /// duplicates collapsed) and returns what was actually saved. A tag's name
  /// is stored once in `tags` and reused by every entry that has it (ADR-002
  /// update 2026-09-23).
  Future<List<String>> _setTags(int entryId, List<String> tags) async {
    await (_db.delete(_db.entryTags)..where((et) => et.entryId.equals(entryId))).go();
    final saved = <String>[];
    for (final raw in tags) {
      final name = raw.trim();
      if (name.isEmpty || saved.contains(name)) continue;
      final existing = await (_db.select(_db.tags)..where((t) => t.name.equals(name))).getSingleOrNull();
      final tagId = existing?.id ?? await _db.into(_db.tags).insert(TagsCompanion.insert(name: name));
      await _db.into(_db.entryTags).insert(EntryTagsCompanion.insert(entryId: entryId, tagId: tagId));
      saved.add(name);
    }
    return saved;
  }

  Future<List<String>> _tagsFor(int entryId) async {
    final q = _db.select(_db.tags).join([innerJoin(_db.entryTags, _db.entryTags.tagId.equalsExp(_db.tags.id))])
      ..where(_db.entryTags.entryId.equals(entryId));
    final rows = await q.get();
    return [for (final r in rows) r.readTable(_db.tags).name];
  }

  /// Deletes an entry for good (AC-6), and every one of its photos with it -
  /// FEAT-011 AC-4, the same permanence rule entry text already has.
  Future<void> delete(int id) => _db.transaction(() async {
        final photos = await (_db.select(_db.media)..where((m) => m.entryId.equals(id))).get();
        await (_db.delete(_db.media)..where((m) => m.entryId.equals(id))).go();
        await (_db.delete(_db.entries)..where((e) => e.id.equals(id))).go();
        final draft = await _loadDraftRow();
        if (draft?.entryId == id) await _clearDraft();
        for (final photo in photos) {
          await _media?.delete(photo.uid);
        }
      });

  /// Encrypts and saves a photo already picked and compressed by the caller
  /// (FEAT-011 AC-1); [mimeType] and [caption] travel with it. Requires the
  /// repository to have been built with a media directory and a data key.
  Future<StoredPhoto> addPhoto({
    required int entryId,
    required Uint8List bytes,
    required String mimeType,
    String? caption,
  }) =>
      _addPhotoWithUid(newEntryUid(), entryId: entryId, bytes: bytes, mimeType: mimeType, caption: caption);

  /// Import (FEAT-011, ADR-003 update 2026-09-23) re-uses this with the
  /// archive's own `uid` for each photo, the same way [importEntries]
  /// keeps an entry's original `uid` rather than minting a new one.
  Future<StoredPhoto> _addPhotoWithUid(
    String uid, {
    required int entryId,
    required Uint8List bytes,
    required String mimeType,
    String? caption,
  }) async {
    final media = _media!;
    final hash = sha256Hex(bytes);
    await media.write(uid, bytes);
    try {
      await _db.into(_db.media).insert(MediaCompanion.insert(
            uid: uid,
            entryId: entryId,
            caption: Value(caption),
            mimeType: mimeType,
            byteSize: bytes.length,
            sha256: hash,
            createdAtMs: _nowMs(),
          ));
    } catch (_) {
      // The row failed after the file was written: remove the orphan rather
      // than leave a file no `media` row points to (ADR-002's known risk).
      await media.delete(uid);
      rethrow;
    }
    return StoredPhoto(uid: uid, entryId: entryId, caption: caption, mimeType: mimeType, byteSize: bytes.length, sha256: hash, createdAtMs: _nowMs());
  }

  /// Removes a photo for good (FEAT-011 AC-3): its `media` row first, then
  /// its file, so a crash in between leaves an orphaned file, never a row
  /// pointing at nothing.
  Future<void> removePhoto(String uid) => _db.transaction(() async {
        await (_db.delete(_db.media)..where((m) => m.uid.equals(uid))).go();
        await _media?.delete(uid);
      });

  /// Changes a photo's caption, or clears it with `null` (FEAT-011 AC-9).
  Future<bool> setPhotoCaption(String uid, String? caption) async {
    final changed = await (_db.update(_db.media)..where((m) => m.uid.equals(uid))).write(MediaCompanion(caption: Value(caption)));
    return changed > 0;
  }

  /// An entry's photos, in the order they were added. No bytes: call
  /// [readPhotoBytes] for one photo's actual content, since that is the
  /// expensive part a list of thumbnails should not pay for every photo at once.
  Future<List<StoredPhoto>> photosFor(int entryId) async {
    final rows = await (_db.select(_db.media)
          ..where((m) => m.entryId.equals(entryId))
          ..orderBy([(m) => OrderingTerm.asc(m.id)]))
        .get();
    return [
      for (final r in rows)
        StoredPhoto(uid: r.uid, entryId: r.entryId, caption: r.caption, mimeType: r.mimeType, byteSize: r.byteSize, sha256: r.sha256, createdAtMs: r.createdAtMs),
    ];
  }

  /// Decrypts one photo's bytes (FEAT-011 AC-2). Throws if the file is
  /// missing, damaged, or was encrypted under a different key (AC-8).
  Future<Uint8List> readPhotoBytes(String uid) => _media!.read(uid);

  Future<JournalEntry?> get(int id) async {
    final row = await (_db.select(_db.entries)..where((e) => e.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final tags = await _tagsFor(id);
    return JournalEntry(id: row.id, uid: row.uid, day: row.day, body: row.body, mood: Mood.fromIndex(row.mood), tags: tags);
  }

  /// Newest day first; inside a day, the most recently written first.
  Stream<List<JournalEntry>> watchAll() {
    final q = _db.select(_db.entries)
      ..orderBy([
        (e) => OrderingTerm.desc(e.day),
        (e) => OrderingTerm.desc(e.id),
      ]);
    return q.watch().map(
          (rows) => [for (final r in rows) JournalEntry(id: r.id, uid: r.uid, day: r.day, body: r.body)],
        );
  }

  /// The timeline: newest day first, and inside a day the most recently written
  /// first (FEAT-002 AC-1). Only a short preview of each text is read, so a
  /// journal of 20,000 entries does not have to be held in memory (AC-4).
  Stream<List<TimelineItem>> watchTimeline({int previewLength = 240}) {
    return _db
        .customSelect(
          'SELECT e.id AS id, e.day AS day, e.created_at_ms AS created_at_ms, substr(e.body, 1, ?) AS preview, e.mood AS mood, '
          '(SELECT GROUP_CONCAT(t.name, char(1)) FROM entry_tags et JOIN tags t ON t.id = et.tag_id WHERE et.entry_id = e.id) AS tags '
          'FROM entries e ORDER BY e.day DESC, e.id DESC',
          variables: [Variable<int>(previewLength)],
          readsFrom: {_db.entries, _db.entryTags, _db.tags},
        )
        .watch()
        .map((rows) => [
              for (final r in rows)
                TimelineItem(
                  id: r.read<int>('id'),
                  day: r.read<String>('day'),
                  createdAtMs: r.read<int>('created_at_ms'),
                  preview: r.read<String>('preview'),
                  mood: Mood.fromIndex(r.readNullable<int>('mood')),
                  tags: _splitTags(r.readNullable<String>('tags')),
                ),
            ]);
  }

  /// Entries written on the same calendar day in an earlier year, most recent
  /// year first (FEAT-010 AC-5, AC-6; ordering is a UX proposal, not yet
  /// confirmed by the owner, `ux-design/report/user-flows.md` F8). Today's own
  /// entries are excluded: only a different year with the same month and day
  /// counts. Empty when nothing matches, so the caller shows no card (AC-6).
  Stream<List<TimelineItem>> watchOnThisDay(String today, {int previewLength = 240}) {
    final monthDay = today.substring(5); // 'MM-dd'
    return _db
        .customSelect(
          'SELECT id, day, created_at_ms, substr(body, 1, ?) AS preview '
          'FROM entries WHERE substr(day, 6, 5) = ? AND day != ? '
          'ORDER BY day DESC, id DESC',
          variables: [Variable<int>(previewLength), Variable<String>(monthDay), Variable<String>(today)],
          readsFrom: {_db.entries},
        )
        .watch()
        .map((rows) => [
              for (final r in rows)
                TimelineItem(
                  id: r.read<int>('id'),
                  day: r.read<String>('day'),
                  createdAtMs: r.read<int>('created_at_ms'),
                  preview: r.read<String>('preview'),
                ),
            ]);
  }

  /// Entries that contain the words typed, newest first (FEAT-005). Case and accents
  /// are ignored. At most [limit] results are returned.
  Future<List<SearchHit>> search(String input, {int limit = 500}) async {
    final query = searchQueryFor(input);
    if (query == null) return const [];
    final rows = await _db.customSelect(
      'SELECT e.id AS id, e.day AS day, e.created_at_ms AS created_at_ms, '
      "snippet(entries_fts, 0, char(1), char(2), '…', 24) AS snip "
      'FROM entries_fts JOIN entries e ON e.id = entries_fts.rowid '
      'WHERE entries_fts MATCH ? ORDER BY e.day DESC, e.id DESC LIMIT ?',
      variables: [Variable<String>(query), Variable<int>(limit)],
    ).get();
    return [
      for (final r in rows)
        SearchHit(
          id: r.read<int>('id'),
          day: r.read<String>('day'),
          createdAtMs: r.read<int>('created_at_ms'),
          snippet: r.read<String>('snip'),
        ),
    ];
  }

  Future<int> count() async {
    final c = _db.entries.id.count();
    final row = await (_db.selectOnly(_db.entries)..addColumns([c])).getSingle();
    return row.read(c)!;
  }

  // ---- export and import (FEAT-006, FEAT-007) -----------------------------

  /// Every entry, oldest first, for an export. `media` lists each photo's
  /// metadata only (FEAT-011); the caller reads its actual bytes separately,
  /// through [readPhotoBytes], since decrypting every photo up front would
  /// hold far more in memory than an export needs at once.
  Future<List<StoredEntry>> readAllForExport() async {
    final rows = await _db.customSelect(
      'SELECT e.uid AS uid, e.day AS day, e.body AS body, e.created_at_ms AS created_at_ms, e.updated_at_ms AS updated_at_ms, e.mood AS mood, '
      '(SELECT GROUP_CONCAT(t.name, char(1)) FROM entry_tags et JOIN tags t ON t.id = et.tag_id WHERE et.entry_id = e.id) AS tags '
      'FROM entries e ORDER BY e.day ASC, e.id ASC',
      readsFrom: {_db.entries, _db.entryTags, _db.tags},
    ).get();
    final mediaRows = await _db.customSelect(
      'SELECT e.uid AS entry_uid, m.uid AS uid, m.caption AS caption, m.mime_type AS mime_type '
      'FROM media m JOIN entries e ON e.id = m.entry_id ORDER BY e.uid ASC, m.id ASC',
      readsFrom: {_db.media, _db.entries},
    ).get();
    final mediaByEntry = <String, List<StoredMediaRef>>{};
    for (final r in mediaRows) {
      (mediaByEntry[r.read<String>('entry_uid')] ??= []).add(StoredMediaRef(
        uid: r.read<String>('uid'),
        mimeType: r.read<String>('mime_type'),
        caption: r.readNullable<String>('caption'),
      ));
    }
    return [
      for (final r in rows)
        StoredEntry(
          uid: r.read<String>('uid'),
          day: r.read<String>('day'),
          text: r.read<String>('body'),
          createdAtMs: r.read<int>('created_at_ms'),
          updatedAtMs: r.read<int>('updated_at_ms'),
          mood: Mood.fromIndex(r.readNullable<int>('mood')),
          tags: _splitTags(r.readNullable<String>('tags')),
          media: mediaByEntry[r.read<String>('uid')] ?? const [],
        ),
    ];
  }

  /// Adds the entries that are not on the phone yet, in ONE transaction: either
  /// all of them are added or none is (FEAT-007 AC-7). An entry whose id is
  /// already here is left exactly as it is and counted as skipped (AC-6, AC-8).
  /// [mediaBytes] holds each photo's plaintext bytes, by [StoredMediaRef.uid]
  /// (FEAT-011): the archive reader supplies this from the ZIP's `media/`
  /// files, decoded and validated separately from the entries themselves. A
  /// photo referenced by an entry but missing from this map (an older,
  /// truncated, or partially-limited archive) is skipped, not an import
  /// failure - the same "ignore what is not understood" rule mood and tags
  /// already follow.
  Future<ImportOutcome> importEntries(List<StoredEntry> entries, {Map<String, Uint8List> mediaBytes = const {}}) =>
      _db.transaction(() async {
        var added = 0;
        var skipped = 0;
        for (final e in entries) {
          final exists = await (_db.select(_db.entries)..where((r) => r.uid.equals(e.uid))).getSingleOrNull();
          if (exists != null) {
            skipped++;
            continue;
          }
          final id = await _db.into(_db.entries).insert(EntriesCompanion.insert(
                uid: e.uid,
                day: e.day,
                body: e.text,
                createdAtMs: e.createdAtMs,
                updatedAtMs: e.updatedAtMs,
                mood: Value(e.mood?.index),
              ));
          await _setTags(id, e.tags);
          for (final ref in e.media) {
            final bytes = mediaBytes[ref.uid];
            if (bytes == null || _media == null) continue;
            await _addPhotoWithUid(ref.uid, entryId: id, bytes: bytes, mimeType: ref.mimeType, caption: ref.caption);
          }
          added++;
        }
        return ImportOutcome(added: added, skipped: skipped);
      });

  static const _lastExportKey = 'last_export_ms';

  /// The time of the last successful export, or null when none was made (FEAT-008).
  Future<DateTime?> lastExportAt() async {
    final row = await (_db.select(_db.appValues)..where((v) => v.name.equals(_lastExportKey))).getSingleOrNull();
    final ms = row == null ? null : int.tryParse(row.value);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// A successful export also ends any snooze: the reminder starts again from a clean state.
  Future<void> recordExport(DateTime at) => _db.transaction(() async {
        await _db.into(_db.appValues).insertOnConflictUpdate(
              AppValuesCompanion.insert(name: _lastExportKey, value: at.millisecondsSinceEpoch.toString()),
            );
        await (_db.delete(_db.appValues)..where((v) => v.name.equals(_dismissedKey))).go();
      });

  static const _dismissedKey = 'reminder_dismissed_ms';

  Future<void> dismissReminder(DateTime at) => _db.into(_db.appValues).insertOnConflictUpdate(
        AppValuesCompanion.insert(name: _dismissedKey, value: at.millisecondsSinceEpoch.toString()),
      );

  /// What the export reminder needs to decide (FEAT-008); it never reads entry text.
  Future<ReminderInputs> reminderInputs() async {
    final last = await lastExportAt();
    final dismissedRow = await (_db.select(_db.appValues)..where((v) => v.name.equals(_dismissedKey))).getSingleOrNull();
    final dismissedMs = dismissedRow == null ? null : int.tryParse(dismissedRow.value);
    final total = await count();
    var changed = total > 0;
    if (last != null && total > 0) {
      final newer = _db.entries.id.count();
      final row = await (_db.selectOnly(_db.entries)
            ..addColumns([newer])
            ..where(_db.entries.updatedAtMs.isBiggerThanValue(last.millisecondsSinceEpoch)))
          .getSingle();
      changed = row.read(newer)! > 0;
    }
    return ReminderInputs(
      entryCount: total,
      lastExport: last,
      changedSinceExport: changed,
      dismissedAt: dismissedMs == null ? null : DateTime.fromMillisecondsSinceEpoch(dismissedMs),
    );
  }

  // ---- settings kept inside the encrypted journal ------------------------

  static const _lockTimeoutKey = 'lock_timeout_s';

  /// Seconds the app may stay away before it locks; null when never chosen (the default, 0, applies).
  Future<int?> lockTimeoutSeconds() async {
    final row = await (_db.select(_db.appValues)..where((v) => v.name.equals(_lockTimeoutKey))).getSingleOrNull();
    return row == null ? null : int.tryParse(row.value);
  }

  Future<void> setLockTimeoutSeconds(int seconds) => _db.into(_db.appValues).insertOnConflictUpdate(
        AppValuesCompanion.insert(name: _lockTimeoutKey, value: seconds.toString()),
      );

  // ---- draft -------------------------------------------------------------

  /// Keeps unsaved text. An empty draft removes the stored one.
  Future<void> saveDraft({int? entryId, required String day, required String body}) async {
    if (isBlank(body)) {
      await _clearDraft();
      return;
    }
    await _db.into(_db.drafts).insertOnConflictUpdate(DraftsCompanion.insert(
          id: const Value(1),
          entryId: Value(entryId),
          day: day,
          body: body,
          updatedAtMs: _nowMs(),
        ));
  }

  Future<EntryDraft?> loadDraft() async {
    final row = await _loadDraftRow();
    return row == null ? null : EntryDraft(entryId: row.entryId, day: row.day, body: row.body);
  }

  Future<void> discardDraft() => _clearDraft();

  Future<Draft?> _loadDraftRow() =>
      (_db.select(_db.drafts)..where((d) => d.id.equals(1))).getSingleOrNull();

  Future<void> _clearDraft() => (_db.delete(_db.drafts)..where((d) => d.id.equals(1))).go();
}
