
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.45,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.forward();

      _navigationTimer = Timer(
        const Duration(milliseconds: 3200),
        _openOnboarding,
      );
    });
  }

  void _openOnboarding() {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const WelcomeScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppColors.lightOrange,
                      borderRadius: BorderRadius.circular(42),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withValues(
                            alpha: 0.16,
                          ),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant_rounded,
                          size: 76,
                          color: AppColors.orange,
                        ),
                        Positioned(
                          right: 22,
                          top: 22,
                          child: Icon(
                            Icons.eco_rounded,
                            size: 32,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'RePlate',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.brown,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Text(
                    'Good Food. Second Chances.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 52),

              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.orange,
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
