
import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'auth_storage.dart';
import 'welcome_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String role;

  const RegisterScreen({
    super.key,
    required this.role,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  bool get _isHotel => widget.role == 'Hotel / Restaurant';

  Color get _roleColor =>
      _isHotel ? AppColors.orange : AppColors.green;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: widget.role,
      );

      final token = result['token'] as String?;
      final user = result['user'] as Map<String, dynamic>?;

      if (token == null || user == null) {
        throw Exception(
          'Invalid registration response from server.',
        );
      }

      // Save the newly registered user's session.
      await AuthStorage.saveSession(
        token: token,
        user: user,
      );

      if (!mounted) return;

      // Show the welcome animation before opening the dashboard.
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(
            name: _nameController.text.trim(),
            role: widget.role,
          ),
        ),
            (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error
          .toString()
          .replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $message'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: _roleColor,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: _roleColor,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.brown,
        elevation: 0,
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        height: 80,
                        width: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isHotel
                              ? AppColors.lightOrange
                              : AppColors.lightGreen,
                          borderRadius:
                          BorderRadius.circular(24),
                        ),
                        child: Icon(
                          _isHotel
                              ? Icons.storefront_rounded
                              : Icons.volunteer_activism_rounded,
                          size: 42,
                          color: _roleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),

                    Text(
                      _isHotel
                          ? 'Join RePlate as a Hotel'
                          : 'Join RePlate as an NGO',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'Create your account and help reduce food waste.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textBrown,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Name
                    TextFormField(
                      controller: _nameController,
                      textCapitalization:
                      TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        label: _isHotel
                            ? 'Hotel / Restaurant name'
                            : 'NGO / Organization name',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: _decoration(
                        label: 'Email address',
                        icon: Icons.email_outlined,
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';

                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Please enter a valid email.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone number (optional)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        label: 'Phone number (optional)',
                        icon: Icons.phone_outlined,
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (phone.isNotEmpty &&
                            phone
                                .replaceAll(
                              RegExp(r'\D'),
                              '',
                            )
                                .length <
                                10) {
                          return 'Please enter a valid phone number.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address (optional)
                    TextFormField(
                      controller: _addressController,
                      textCapitalization:
                      TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      decoration: _decoration(
                        label: 'Address (optional)',
                        icon: Icons.location_on_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _hidePassword,
                      textInputAction: TextInputAction.next,
                      decoration: _decoration(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 8) {
                          return 'Password must be at least 8 characters.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) {
                        if (!_loading) _register();
                      },
                      decoration: _decoration(
                        label: 'Confirm password',
                        icon: Icons.lock_reset_outlined,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword =
                              !_hideConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 26),

                    // Register button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _roleColor,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                          height: 23,
                          width: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                            : const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Good Food. Second Chances.',
                      textAlign: TextAlign.center,
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
      ),
    );
  }
}
