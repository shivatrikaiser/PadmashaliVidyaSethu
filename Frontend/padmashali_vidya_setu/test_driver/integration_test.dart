// Driver for `flutter drive`; saves screenshots taken by the integration test.
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/registration_flow_test.dart -d emulator-5554 --dart-define=SCREENSHOTS=true
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
      onScreenshot: (name, bytes, [args]) async {
        final file = File('../../Docs/ui/screenshots/$name.png');
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
        return true;
      },
    );
