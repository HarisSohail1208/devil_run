import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';
import 'services/audio_service.dart';
import 'services/app_update_service.dart';
import 'services/analytics_service.dart';
import 'services/monetization_service.dart';
import 'services/save_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final saveService = SaveService();
  await saveService.load();
  final audioService = AudioService(saveService);
  await audioService.initialize();
  await MonetizationService.instance.initialize();

  runApp(DevilRunApp(saveService: saveService, audioService: audioService));
  unawaited(AppUpdateService.checkForImmediateUpdate());
}

class DevilRunApp extends StatefulWidget {
  const DevilRunApp({
    required this.saveService,
    required this.audioService,
    super.key,
  });

  final SaveService saveService;
  final AudioService audioService;

  @override
  State<DevilRunApp> createState() => _DevilRunAppState();
}

class _DevilRunAppState extends State<DevilRunApp> {
  @override
  void dispose() {
    widget.audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Devil Run',
      navigatorObservers: Firebase.apps.isEmpty
          ? const []
          : [AnalyticsService.instance.observer],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffffa51f),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Roboto',
      ),
      home: MainMenuScreen(
        saveService: widget.saveService,
        audioService: widget.audioService,
      ),
    );
  }
}
