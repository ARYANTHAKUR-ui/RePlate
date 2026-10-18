
import 'package:flutter/material.dart';
import 'features/onboarding/welcome_screen.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const RePlateApp());
}

class RePlateApp extends StatelessWidget {
  const RePlateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RePlate',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orange,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
