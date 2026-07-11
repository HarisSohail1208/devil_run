import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  const AppUpdateService._();

  static Future<void> checkForImmediateUpdate() async {
    if (!kReleaseMode || defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      final update = await InAppUpdate.checkForUpdate();
      final available =
          update.updateAvailability == UpdateAvailability.updateAvailable ||
          update.updateAvailability ==
              UpdateAvailability.developerTriggeredUpdateInProgress;
      if (available && update.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {
      // Sideloaded builds and devices without Play Store support skip safely.
    }
  }
}
