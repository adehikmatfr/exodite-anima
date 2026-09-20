import 'dart:math';

import 'package:drift/drift.dart';

import '../backup/reminder.dart';
import 'journal_database.dart';

/// A saved entry as the rest of the app sees it.
class JournalEntry {
  const JournalEntry({required this.id, required this.uid, required this.day, required this.body});
  final int id;
  final String uid; // stable identifier used in exports
  final String day; // yyyy-MM-dd
  final String body;
}

/// One row of the timeline: enough to draw the list without loading whole entries.
class TimelineItem {
  const TimelineItem({required this.id, required this.day, required this.createdAtMs, required this.preview});
  final int id;
  final String day; // yyyy-MM-dd
  final int createdAtMs;
  final String preview; // the first characters of the text
}

/// An entry as it travels in an export and an import.
class StoredEntry {
  const StoredEntry({
    required this.uid,
    required this.day,
    required this.text,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  final String uid;
  final String day; // yyyy-MM-dd
  final String text;
  final int createdAtMs;
  final int updatedAtMs;
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
  EntryRepository(this._db, {int Function()? nowMs})
      : _nowMs = nowMs ?? (() => DateTime.now().millisecondsSinceEpoch);

  final JournalDatabase _db;
  final int Function() _nowMs;

  static bool isBlank(String body) => body.trim().isEmpty;

  /// 128 random bits as 32 hex characters.
  static String newEntryUid() {
    final rng = Random.secure();
    return List.generate(16, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
  }

  /// Saves a new entry. Returns null and stores nothing when the text is empty (AC-8).
  Future<JournalEntry?> create({required String day, required String body}) async {
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
          ));
      await _clearDraft();
      return JournalEntry(id: id, uid: uid, day: day, body: body);
    });
  }

  /// Changes text and date of an entry (AC-2, AC-5). False when the text is
  /// empty or the entry does not exist; nothing is changed then.
  Future<bool> update({required int id, required String day, required String body}) async {
    if (isBlank(body)) return false;
    return _db.transaction(() async {
      final changed = await (_db.update(_db.entries)..where((e) => e.id.equals(id))).write(
        EntriesCompanion(day: Value(day), body: Value(body), updatedAtMs: Value(_nowMs())),
      );
      if (changed == 0) return false;
      await _clearDraft();
      return true;
    });
  }

  /// Deletes an entry for good (AC-6). The caller asks for confirmation first (AC-7).
  Future<void> delete(int id) => _db.transaction(() async {
        await (_db.delete(_db.entries)..where((e) => e.id.equals(id))).go();
        final draft = await _loadDraftRow();
        if (draft?.entryId == id) await _clearDraft();
      });

  Future<JournalEntry?> get(int id) async {
    final row = await (_db.select(_db.entries)..where((e) => e.id.equals(id))).getSingleOrNull();
    return row == null ? null : JournalEntry(id: row.id, uid: row.uid, day: row.day, body: row.body);
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
          'SELECT id, day, created_at_ms, substr(body, 1, ?) AS preview '
          'FROM entries ORDER BY day DESC, id DESC',
          variables: [Variable<int>(previewLength)],
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

  /// Every entry, oldest first, for an export.
  Future<List<StoredEntry>> readAllForExport() async {
    final rows = await (_db.select(_db.entries)
          ..orderBy([(e) => OrderingTerm.asc(e.day), (e) => OrderingTerm.asc(e.id)]))
        .get();
    return [
      for (final r in rows)
        StoredEntry(
          uid: r.uid,
          day: r.day,
          text: r.body,
          createdAtMs: r.createdAtMs,
          updatedAtMs: r.updatedAtMs,
        ),
    ];
  }

  /// Adds the entries that are not on the phone yet, in ONE transaction: either
  /// all of them are added or none is (FEAT-007 AC-7). An entry whose id is
  /// already here is left exactly as it is and counted as skipped (AC-6, AC-8).
  Future<ImportOutcome> importEntries(List<StoredEntry> entries) => _db.transaction(() async {
        var added = 0;
        var skipped = 0;
        for (final e in entries) {
          final exists = await (_db.select(_db.entries)..where((r) => r.uid.equals(e.uid))).getSingleOrNull();
          if (exists != null) {
            skipped++;
            continue;
          }
          await _db.into(_db.entries).insert(EntriesCompanion.insert(
                uid: e.uid,
                day: e.day,
                body: e.text,
                createdAtMs: e.createdAtMs,
                updatedAtMs: e.updatedAtMs,
              ));
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
