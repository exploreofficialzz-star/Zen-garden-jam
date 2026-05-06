import 'package:flutter/material.dart';
import 'package:zen_garden_jam_flutter/services/ad_manager.dart';
import 'package:zen_garden_jam_flutter/services/notification_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _animationController.forward();

    // FIX: Initialize platform plugins HERE (after Flutter engine is fully running)
    // rather than blocking main(). If AdMob or notifications fail, the splash
    // screen still shows and the app navigates normally.
    _initServicesAndNavigate();
  }

  Future<void> _initServicesAndNavigate() async {
    // Initialize AdMob — safe, won't crash the app if it fails
    try {
      await AdManager().initialize();
    } catch (e) {
      debugPrint('AdMob init failed (non-fatal): $e');
    }

    // Initialize notifications — safe, won't crash the app if it fails
    try {
      await NotificationManager().initialize();
    } catch (e) {
      debugPrint('Notifications init failed (non-fatal): $e');
    }

    // Wait for at least 3 seconds total splash duration
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 40),
              const Text(
                'Zen Garden Jam',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5016),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Restore the garden, find your peace',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8F6F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 60),
              const CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF9CAF88)),
              ),
              const SizedBox(height: 20),
              const Text(
                'by chAs',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CAF88),
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
