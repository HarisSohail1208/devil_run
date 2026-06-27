import 'package:devil_run/main.dart';
import 'package:devil_run/services/audio_service.dart';
import 'package:devil_run/services/save_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows the main menu', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final saveService = SaveService();
    await saveService.load();
    final audioService = AudioService(saveService);

    await tester.pumpWidget(
      DevilRunApp(saveService: saveService, audioService: audioService),
    );

    expect(find.text('DEVIL RUN'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
  });
}
