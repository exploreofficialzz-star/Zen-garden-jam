import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:zen_garden_jam_flutter/providers/game_provider.dart';
import 'package:zen_garden_jam_flutter/screens/splash_screen.dart';
import 'package:zen_garden_jam_flutter/screens/home_screen.dart';

void main() {
  // runZonedGuarded catches ANY uncaught error in the entire app zone —
  // this prevents the OS "keeps stopping" dialog even if something throws.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Catch Flutter framework errors (widget build exceptions etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };

    // FIX: Initialize timezone database — REQUIRED before any tz.TZDateTime
    // or tz.local usage. flutter_local_notifications uses this internally.
    // Missing this call causes "Invalid argument(s): Unexpected origin" crash.
    tz.initializeTimeZones();

    // FIX: Only initialize GameState (pure Dart/SharedPreferences) before runApp.
    // Plugin initializations (AdMob, Notifications) are deferred to SplashScreen
    // so a platform plugin failure NEVER prevents the app from launching.
    final gameState = GameState();
    await gameState.initialize();

    runApp(ZenGardenJamApp(gameState: gameState));
  }, (error, stack) {
    // Last-resort handler — logs errors instead of crashing
    debugPrint('Uncaught error: $error');
    debugPrint('Stack: $stack');
  });
}

class ZenGardenJamApp extends StatelessWidget {
  final GameState gameState;

  const ZenGardenJamApp({Key? key, required this.gameState}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
