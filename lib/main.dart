import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zen_garden_jam_flutter/providers/game_provider.dart';
import 'package:zen_garden_jam_flutter/services/ad_manager.dart';
import 'package:zen_garden_jam_flutter/services/notification_manager.dart';
import 'package:zen_garden_jam_flutter/screens/splash_screen.dart';
import 'package:zen_garden_jam_flutter/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FIX 1: Initialize AdMob FIRST — must happen before any ad calls.
  // Wrapped in try/catch so an AdMob failure never prevents the app launching.
  try {
    await AdManager().initialize();
  } catch (e) {
    debugPrint('AdManager init error: $e');
  }

  // FIX 2: Fully AWAIT GameState.initialize() before calling runApp.
  // Previously `GameState()..initialize()` inside the Provider create: callback
  // was fire-and-forget. SplashScreen rendered instantly and accessed the `late`
  // _prefs field before SharedPreferences.getInstance() had returned → LateInitializationError crash.
  final gameState = GameState();
  await gameState.initialize();

  // Notifications — non-fatal if it fails
  try {
    await NotificationManager().initialize();
  } catch (e) {
    debugPrint('NotificationManager init error: $e');
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
        // FIX 3: Provide the already-initialised instance, not a fresh one.
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
