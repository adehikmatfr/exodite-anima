/// When to remind the user to export (FEAT-008). Pure, so every boundary is testable.
///
/// Show the reminder when the journal has entries and the newest export does not
/// cover them: either no export was ever made, or the last one is MORE than
/// [reminderAfterDays] calendar days old and entries were added or changed since.
/// Dismissing hides it for [snoozeDays] days.
const reminderAfterDays = 30;
const snoozeDays = 7;

class ReminderInputs {
  const ReminderInputs({
    required this.entryCount,
    required this.lastExport,
    required this.changedSinceExport,
    required this.dismissedAt,
  });
  final int entryCount;
  final DateTime? lastExport;

  /// True when an entry was added or changed after the last export (or no export exists).
  final bool changedSinceExport;
  final DateTime? dismissedAt;
}

enum ReminderKind { none, neverExported, overdue }

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int _daysBetween(DateTime from, DateTime to) => _dateOnly(to).difference(_dateOnly(from)).inDays;

ReminderKind reminderFor(ReminderInputs i, DateTime now) {
  if (i.entryCount == 0) return ReminderKind.none;
  final dismissed = i.dismissedAt;
  if (dismissed != null && _daysBetween(dismissed, now) < snoozeDays) return ReminderKind.none;
  final last = i.lastExport;
  if (last == null) return ReminderKind.neverExported;
  if (!i.changedSinceExport) return ReminderKind.none;
  return _daysBetween(last, now) > reminderAfterDays ? ReminderKind.overdue : ReminderKind.none;
}
