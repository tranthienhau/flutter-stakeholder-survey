import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    // Path used when the on-device test calls binding.takeScreenshot(name).
    onScreenshot: (String name, List<int> bytes, [Map<String, Object?>? args]) async {
      final file = File('screenshots/$name.png');
      await file.create(recursive: true);
      await file.writeAsBytes(bytes);
      return true;
    },
    // Path used by this POC: the test renders each screen with
    // RepaintBoundary.toImage and ships base64 PNGs back via reportData,
    // because the iOS Simulator filesystem is read-only inside the test and
    // the GPU surface-capture path returns blank frames on this simulator.
    responseDataCallback: (Map<String, dynamic>? data) async {
      if (data == null) return;
      final shots = data['shots'];
      if (shots is Map) {
        for (final entry in shots.entries) {
          final name = entry.key as String;
          final b64 = entry.value as String;
          final file = File('screenshots/$name.png');
          await file.create(recursive: true);
          await file.writeAsBytes(base64Decode(b64));
          stdout.writeln('wrote screenshots/$name.png');
        }
      }
    },
  );
}
