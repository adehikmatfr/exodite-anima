// Runs the FEAT-001 storage tests on a device or emulator (real Android build).
import 'package:integration_test/integration_test.dart';

import '../test/entry_repository_test.dart' as storage;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  storage.main();
}
