
import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../food/hotel_dashboard_screen.dart';
import '../home/ngo_dashboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final String name;
  final String role;

  const WelcomeScreen({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;

  Timer? _navigationTimer;

  bool get _isHotel => widget.role == 'Hotel / Restaurant';

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start after the first frame has been rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.forward();

      _navigationTimer = Timer(
        const Duration(milliseconds: 4000),
        _goToDashboard,
      );
    });
  }

  void _goToDashboard() {
    if (!mounted) return;

    final Widget dashboard = _isHotel
        ? const HotelDashboardScreen()
        : const NgoDashboardScreen();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => dashboard,
      ),
          (route) => false,
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
    final roleName = _isHotel
        ? 'Hotel / Restaurant'
        : 'NGO / Organization';

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        color: AppColors.lightOrange,
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.orange.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.restaurant_rounded,
                            size: 68,
                            color: AppColors.orange,
                          ),
                          Positioned(
                            right: 20,
                            top: 20,
                            child: Icon(
                              Icons.eco_rounded,
                              size: 30,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                FadeTransition(
                  opacity: _fade,
                  child: const Text(
                    'RePlate',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: AppColors.brown,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SlideTransition(
                  position: _slide,
                  child: FadeTransition(
                    opacity: _fade,
                    child: Column(
                      children: [
                        Text(
                          'Welcome, ${widget.name}!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.orange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your journey as a $roleName starts here.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: AppColors.textBrown,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Good Food. Second Chances.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 42),

                FadeTransition(
                  opacity: _fade,
                  child: const Column(
                    children: [
                      SizedBox(
                        height: 26,
                        width: 26,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.orange,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Preparing your dashboard...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textBrown,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
