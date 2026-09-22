import 'package:flutter/material.dart';

import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.45,
          curve: Curves.easeOut,
        ),
      ),
    );

    _logoScale = Tween<double>(
      begin: 0.80,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.55,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.40,
          0.75,
          curve: Curves.easeIn,
        ),
      ),
    );

    _controller.forward();

    Future.delayed(
      const Duration(milliseconds: 3000),
      _goToLogin,
    );
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF42A5F5),
              Color(0xFF0946DC),
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/splash_recettescarnet.png',
                  width: 300,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 25),

              FadeTransition(
                opacity: _textOpacity,
                child: const Text(
                  'Le goût du monde\ndans votre carnet !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),

              const Spacer(),

              FadeTransition(
                opacity: _textOpacity,
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 45),
                  child: SizedBox(
                    width: 130,
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Color(0x559AB2D5),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}