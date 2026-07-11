import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  ReviewService._();

  static const _requestedKey = 'in_app_review_requested';

  static Future<void> requestAfterMilestone(int completedLevel) async {
    if (completedLevel < 3) return;
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_requestedKey) ?? false) return;

    final review = InAppReview.instance;
    if (!await review.isAvailable()) return;
    await preferences.setBool(_requestedKey, true);
    await review.requestReview();
  }
}
