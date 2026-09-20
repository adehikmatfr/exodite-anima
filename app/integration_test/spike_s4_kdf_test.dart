// ignore_for_file: avoid_print
// Spike S4: how long does Argon2id take with candidate parameters? (synthetic passcode)
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('S4 Argon2id timings', (t) async {
    final salt = List<int>.generate(16, (i) => i);
    final sets = <(int, int, int)>[
      (19456, 2, 1), // 19 MiB, 2 passes (OWASP minimum guidance)
      (32768, 3, 1), // 32 MiB, 3 passes
      (65536, 3, 1), // 64 MiB, 3 passes
      (65536, 3, 2), // 64 MiB, 3 passes, 2 lanes
    ];
    for (final (mem, iter, par) in sets) {
      final algo = Argon2id(
        memory: mem,
        parallelism: par,
        iterations: iter,
        hashLength: 32,
      );
      // five runs each: the first run is often slower (cold code), so report all
      final ms = <int>[];
      for (var run = 0; run < 5; run++) {
        final sw = Stopwatch()..start();
        final key = await algo.deriveKeyFromPassword(
          password: 'made-up passcode',
          nonce: salt,
        );
        final bytes = await key.extractBytes();
        ms.add(sw.elapsedMilliseconds);
        expect(bytes.length, 32);
      }
      final sorted = [...ms]..sort();
      print(
        'KDF m=${mem ~/ 1024}MiB t=$iter p=$par -> runs $ms ms, median ${sorted[2]} ms, worst ${sorted.last} ms',
      );
    }
  }, timeout: const Timeout(Duration(minutes: 10)));
}
