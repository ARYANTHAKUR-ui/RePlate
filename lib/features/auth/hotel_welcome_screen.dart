
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../food/hotel_dashboard_screen.dart';

class HotelWelcomeScreen extends StatefulWidget {
  final String hotelName;

  const HotelWelcomeScreen({
    super.key,
    required this.hotelName,
  });

  @override
  State<HotelWelcomeScreen> createState() =>
      _HotelWelcomeScreenState();
}

class _HotelWelcomeScreenState
    extends State<HotelWelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.65,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _startWelcome();
  }

  Future<void> _startWelcome() async {
    await _controller.forward();

    await Future.delayed(
      const Duration(milliseconds: 1800),
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HotelDashboardScreen(),
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
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        color: AppColors.lightOrange,
                        borderRadius:
                        BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange
                                .withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volunteer_activism_rounded,
                        size: 58,
                        color: AppColors.orange,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'RePlate',
                    style: TextStyle(
                      color: AppColors.brown,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const Text(
                          'Welcome aboard,',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textBrown,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          widget.hotelName.trim().isEmpty
                              ? 'Your Hotel'
                              : widget.hotelName.trim(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.orange,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Together, let’s turn surplus food '
                              'into meaningful meals.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textBrown,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 38),

                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.green,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Preparing your dashboard...',
                    style: TextStyle(
                      color: AppColors.textBrown,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
