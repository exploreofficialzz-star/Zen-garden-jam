import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zen_garden_jam_flutter/providers/game_provider.dart';

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

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
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
              // App Icon
              Image.asset(
                'assets/images/app_icon.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 40),
              // App Title
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
              // Tagline
              const Text(
                'Restore the garden, find your peace',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF7A8F6F),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 60),
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9CAF88)),
              ),
              const SizedBox(height: 20),
              // By chAs
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
