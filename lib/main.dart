import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/main_menu_screen.dart';
import 'services/audio_service.dart';
import 'services/save_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final saveService = SaveService();
  await saveService.load();
  final audioService = AudioService(saveService);
  await audioService.initialize();

  runApp(DevilRunApp(saveService: saveService, audioService: audioService));
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
