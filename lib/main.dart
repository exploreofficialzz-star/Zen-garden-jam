import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zen_garden_jam_flutter/providers/game_provider.dart';
import 'package:zen_garden_jam_flutter/services/ad_manager.dart';
import 'package:zen_garden_jam_flutter/services/notification_manager.dart';
import 'package:zen_garden_jam_flutter/screens/splash_screen.dart';
import 'package:zen_garden_jam_flutter/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await AdManager().initialize();
  await NotificationManager().initialize();
  
  runApp(const ZenGardenJamApp());
}

class ZenGardenJamApp extends StatelessWidget {
  const ZenGardenJamApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameState()..initialize(),
        ),
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
