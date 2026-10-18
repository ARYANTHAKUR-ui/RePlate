
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'role_selection_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _continue(context),
                          child: const Text(
                            'Skip  →',
                            style: TextStyle(
                              color: AppColors.textBrown,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Container(
                        width: 138,
                        height: 138,
                        decoration: BoxDecoration(
                          color: AppColors.lightOrange,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Icon(
                              Icons.eco_rounded,
                              size: 94,
                              color: AppColors.green,
                            ),
                            Positioned(
                              bottom: 19,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: const BoxDecoration(
                                  color: AppColors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.volunteer_activism_rounded,
                                  color: Colors.white,
                                  size: 37,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 43,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'Re',
                              style: TextStyle(
                                color: AppColors.brown,
                              ),
                            ),
                            TextSpan(
                              text: 'Plate',
                              style: TextStyle(
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        'Good Food. Second Chances.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.brown,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Connecting hotels and restaurants with NGOs '
                            'to give surplus food a new purpose.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textBrown,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Row(
                        children: [
                          _Benefit(
                            icon: Icons.restaurant_rounded,
                            label: 'Reduce\nFood Waste',
                            color: AppColors.orange,
                          ),
                          _Benefit(
                            icon: Icons.groups_rounded,
                            label: 'Support\nCommunities',
                            color: AppColors.green,
                          ),
                          _Benefit(
                            icon: Icons.eco_rounded,
                            label: 'A Greener\nFuture',
                            color: AppColors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Container(
                        height: 155,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE7CA),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              left: 22,
                              top: 17,
                              child: Icon(
                                Icons.eco_rounded,
                                size: 42,
                                color: AppColors.green.withOpacity(0.65),
                              ),
                            ),
                            Positioned(
                              right: 22,
                              top: 15,
                              child: Icon(
                                Icons.spa_rounded,
                                size: 35,
                                color: AppColors.orange.withOpacity(0.7),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.volunteer_activism_rounded,
                                  size: 67,
                                  color: AppColors.orange,
                                ),
                                const SizedBox(height: 7),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 17,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Good Food, Shared with Care',
                                    style: TextStyle(
                                      color: AppColors.brown,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 26),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () => _continue(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orange,
                            foregroundColor: AppColors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.arrow_forward_rounded),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'Rescue food. Reduce waste. Feed communities.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textBrown,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _continue(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoleSelectionScreen(),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Benefit({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 29),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.brown,
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
