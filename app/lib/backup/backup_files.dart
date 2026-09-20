import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum ShareOutcome { shared, cancelled }

/// How an export leaves the app and how an import file comes in. Both go
/// through the phone's own dialogs, which need no storage permission; the app
/// never uploads anything (ADR-005).
abstract class BackupFiles {
  /// Hands [bytes] to the phone's share or save dialog.
  Future<ShareOutcome> share({required Uint8List bytes, required String fileName});

  /// Lets the user choose a file. Null when they cancel.
  Future<Uint8List?> pick();
}

class SystemBackupFiles implements BackupFiles {
  Directory? _dir;

  Future<Directory> _exportDir() async {
    final base = await getTemporaryDirectory();
    return _dir ??= await Directory(p.join(base.path, 'exports')).create(recursive: true);
  }

  /// Removes export files left in the cache (called at start and after sharing).
  Future<void> clearLeftovers() async {
    final dir = await _exportDir();
    for (final f in dir.listSync()) {
      try {
        f.deleteSync(recursive: true);
      } catch (_) {}
    }
  }

  @override
  Future<ShareOutcome> share({required Uint8List bytes, required String fileName}) async {
    final dir = await _exportDir();
    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    try {
      final result = await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], subject: fileName));
      return result.status == ShareResultStatus.dismissed ? ShareOutcome.cancelled : ShareOutcome.shared;
    } finally {
      // The receiving app may still be reading the file; remove it a little later.
      Timer(const Duration(minutes: 2), () {
        try {
          file.deleteSync();
        } catch (_) {}
      });
    }
  }

  @override
  Future<Uint8List?> pick() async {
    final picked = await FilePicker.pickFile();
    final path = picked?.path;
    if (path == null) return null;
    try {
      return await File(path).readAsBytes();
    } finally {
      unawaited(FilePicker.clearTemporaryFiles());
    }
  }
}

/// For tests only: nothing leaves the phone, and the "picked" file is set by the test.
class FakeBackupFiles implements BackupFiles {
  FakeBackupFiles({this.picked, this.shareOutcome = ShareOutcome.shared, this.shareFails = false});
  Uint8List? picked;
  ShareOutcome shareOutcome;
  bool shareFails;
  Uint8List? lastShared;
  String? lastSharedName;

  @override
  Future<ShareOutcome> share({required Uint8List bytes, required String fileName}) async {
    if (shareFails) throw const FileSystemException('disk full');
    lastShared = bytes;
    lastSharedName = fileName;
    return shareOutcome;
  }

  @override
  Future<Uint8List?> pick() async => picked;
}
