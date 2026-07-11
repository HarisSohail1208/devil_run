import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AnalyticsService {
  AnalyticsService._();

  static final instance = AnalyticsService._();
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: analytics);

  Future<void> logLevelStart(int levelIndex) async {
    if (Firebase.apps.isEmpty) return;
    await analytics.logEvent(
      name: 'level_start',
      parameters: {'level_number': levelIndex + 1},
    );
  }

  Future<void> logLevelComplete(int levelIndex) async {
    if (Firebase.apps.isEmpty) return;
    await analytics.logEvent(
      name: 'level_complete',
      parameters: {'level_number': levelIndex + 1},
    );
  }
}
