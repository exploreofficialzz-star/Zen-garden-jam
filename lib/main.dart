import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zen_garden_jam_flutter/providers/game_provider.dart';
import 'package:zen_garden_jam_flutter/services/ad_manager.dart';
import 'package:zen_garden_jam_flutter/services/notification_manager.dart';
import 'package:zen_garden_jam_flutter/screens/splash_screen.dart';
import 'package:zen_garden_jam_flutter/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX: Initialize GameState FIRST and AWAIT it before runApp.
  // Previously `GameState()..initialize()` was fire-and-forget inside the
  // Provider create callback — _prefs (late field) was unset when the first
  // frame tried to read it, causing LateInitializationError crash.
  final gameState = GameState();
  await gameState.initialize();

  // Initialize services — wrapped in try/catch so ad/notification failures
  // never prevent the app from launching.
  try {
    await AdManager().initialize();
  } catch (e) {
    debugPrint('AdManager init failed: $e');
  }

  try {
    await NotificationManager().initialize();
  } catch (e) {
    debugPrint('NotificationManager init failed: $e');
  }

  runApp(ZenGardenJamApp(gameState: gameState));
}

class ZenGardenJamApp extends StatelessWidget {
  final GameState gameState;

  const ZenGardenJamApp({Key? key, required this.gameState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // FIX: Pass the already-initialised instance instead of creating a new one.
        ChangeNotifierProvider<GameState>.value(value: gameState),
      ],
      child: MaterialApp(
        title: 'Zen Garden Jam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9CAF88),
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
