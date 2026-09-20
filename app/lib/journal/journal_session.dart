import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/data_key_source.dart';
import '../data/entry_repository.dart';
import '../data/journal_database.dart';

/// The result of trying to open the journal at start-up.
sealed class SessionResult {}

class SessionOpen extends SessionResult {
  SessionOpen(this.database, this.repository);
  final JournalDatabase database;
  final EntryRepository repository;
}

class SessionCannotOpen extends SessionResult {}

class SessionTooNew extends SessionResult {}

/// Opens the journal file in the app's private storage.
Future<SessionResult> openJournal({required DataKeySource keySource, Directory? directory}) async {
  final source = keySource;
  try {
    final dir = directory ?? await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, 'journal.db'));
    final db = await JournalDatabase.openEncrypted(file, await source.load());
    return SessionOpen(db, EntryRepository(db));
  } on JournalTooNewException {
    return SessionTooNew();
  } catch (_) {
    return SessionCannotOpen();
  }
}
