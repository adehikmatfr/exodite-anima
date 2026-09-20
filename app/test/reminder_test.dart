// FEAT-008 export reminder rules and the numbers behind them.
import 'dart:io';
import 'dart:typed_data';

import 'package:exoditeanima/backup/reminder.dart';
import 'package:exoditeanima/data/entry_repository.dart';
import 'package:exoditeanima/data/journal_database.dart';
import 'package:flutter_test/flutter_test.dart';

ReminderInputs inputs({int entries = 5, DateTime? last, bool changed = true, DateTime? dismissed}) =>
    ReminderInputs(entryCount: entries, lastExport: last, changedSinceExport: changed, dismissedAt: dismissed);

void main() {
  final now = DateTime(2026, 9, 20, 14, 30);

  group('rules', () {
    test('AC-1 no export ever and entries exist: shown', () {
      expect(reminderFor(inputs(), now), ReminderKind.neverExported);
    });

    test('an empty journal never gets a reminder', () {
      expect(reminderFor(inputs(entries: 0), now), ReminderKind.none);
    });

    test('AC-2 a recent export and nothing new since: not shown', () {
      expect(reminderFor(inputs(last: now.subtract(const Duration(days: 3)), changed: false), now), ReminderKind.none);
    });

    test('a recent export with new entries is not shown either (only 30 days or more)', () {
      expect(reminderFor(inputs(last: now.subtract(const Duration(days: 3))), now), ReminderKind.none);
    });

    test('AC-3 older than 30 days and new entries: shown', () {
      expect(reminderFor(inputs(last: now.subtract(const Duration(days: 45))), now), ReminderKind.overdue);
    });

    test('an old export with no new entries since is not shown', () {
      expect(reminderFor(inputs(last: now.subtract(const Duration(days: 45)), changed: false), now), ReminderKind.none);
    });

    test('AC-7 exactly 30 days: not shown; one day later: shown', () {
      final last = DateTime(2026, 8, 21, 23, 59); // 30 calendar days before 20 Sep, late in the day
      expect(reminderFor(inputs(last: last), now), ReminderKind.none);
      expect(reminderFor(inputs(last: last), now.add(const Duration(days: 1))), ReminderKind.overdue);
    });

    test('the time of day does not move the boundary', () {
      final last = DateTime(2026, 8, 21, 0, 1);
      expect(reminderFor(inputs(last: last), DateTime(2026, 9, 20, 23, 59)), ReminderKind.none);
      expect(reminderFor(inputs(last: last), DateTime(2026, 9, 21, 0, 1)), ReminderKind.overdue);
    });

    test('AC-4 dismissed: hidden for 7 days, back on the 7th day after', () {
      final dismissed = DateTime(2026, 9, 20, 9);
      expect(reminderFor(inputs(dismissed: dismissed), now), ReminderKind.none);
      expect(reminderFor(inputs(dismissed: dismissed), DateTime(2026, 9, 26, 23, 0)), ReminderKind.none);
      expect(reminderFor(inputs(dismissed: dismissed), DateTime(2026, 9, 27, 8, 0)), ReminderKind.neverExported);
    });

    test('it returns only if the condition still holds', () {
      final dismissed = DateTime(2026, 9, 1);
      expect(reminderFor(inputs(dismissed: dismissed, last: DateTime(2026, 9, 25), changed: true), DateTime(2026, 10, 10)), ReminderKind.none);
    });
  });

  group('from the journal', () {
    late Directory dir;
    late JournalDatabase db;
    late EntryRepository repo;
    var clock = 1000000;

    setUp(() async {
      dir = Directory.systemTemp.createTempSync('exodite_reminder_');
      db = await JournalDatabase.openEncrypted(File('${dir.path}/journal.db'), Uint8List.fromList(List.generate(32, (i) => i + 9)));
      clock = 1000000;
      repo = EntryRepository(db, nowMs: () => clock += 1000);
    });
    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    test('counts entries, sees new ones after an export, and keeps the snooze', () async {
      var i = await repo.reminderInputs();
      expect(i.entryCount, 0);
      await repo.create(day: '2026-09-01', body: 'one');
      i = await repo.reminderInputs();
      expect((i.entryCount, i.lastExport, i.changedSinceExport), (1, null, true));

      final exportAt = DateTime.fromMillisecondsSinceEpoch(clock + 5000);
      await repo.recordExport(exportAt);
      i = await repo.reminderInputs();
      expect(i.changedSinceExport, isFalse, reason: 'everything is covered by the export');

      clock += 60000;
      await repo.create(day: '2026-09-02', body: 'two');
      i = await repo.reminderInputs();
      expect(i.changedSinceExport, isTrue);

      await repo.dismissReminder(DateTime(2026, 9, 20));
      expect((await repo.reminderInputs()).dismissedAt, DateTime(2026, 9, 20));
      await repo.recordExport(DateTime.fromMillisecondsSinceEpoch(clock + 5000));
      expect((await repo.reminderInputs()).dismissedAt, isNull, reason: 'a successful export ends the snooze (AC-5)');
    });

    test('an edit after the export counts as new', () async {
      final e = (await repo.create(day: '2026-09-01', body: 'one'))!;
      await repo.recordExport(DateTime.fromMillisecondsSinceEpoch(clock + 2000));
      expect((await repo.reminderInputs()).changedSinceExport, isFalse);
      clock += 60000;
      await repo.update(id: e.id, day: '2026-09-01', body: 'one, changed');
      expect((await repo.reminderInputs()).changedSinceExport, isTrue);
    });
  });
}
