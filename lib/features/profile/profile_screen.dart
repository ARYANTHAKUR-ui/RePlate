
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../onboarding/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String role;
  final String userName;
  final String email;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.role = 'NGO / Organization',
    this.userName = 'RePlate User',
    this.email = 'user@replate.demo',
    this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;

  bool get _isHotel => widget.role == 'Hotel / Restaurant';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userName);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.brown,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(
      text: _nameController.text,
    );
    final emailController = TextEditingController(
      text: _emailController.text,
    );

    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cream,
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name / Organization',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textBrown),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (saved == true && mounted) {
      setState(() {
        _nameController.text = nameController.text.trim();
        _emailController.text = emailController.text.trim();
      });
      _showMessage(
        'Profile updated for this session. Connect a backend to save it permanently.',
      );
    }

    nameController.dispose();
    emailController.dispose();
  }

  void _logout() {
    if (widget.onLogout != null) {
      widget.onLogout!();
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.brown,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = AppColors.orange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            color: AppColors.lightOrange,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.brown,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textBrown,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textBrown,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRoleCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isHotel ? Icons.restaurant : Icons.volunteer_activism,
              color: AppColors.green,
              size: 27,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isHotel ? 'Food Partner' : 'Community Partner',
                  style: const TextStyle(
                    color: AppColors.brown,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.role,
                  style: const TextStyle(
                    color: AppColors.textBrown,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_outlined, color: AppColors.green),
        ],
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
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.orange,
                    Color(0xFFFF884D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.cream,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _isHotel
                          ? Icons.storefront_rounded
                          : Icons.volunteer_activism_rounded,
                      size: 43,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _nameController.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _emailController.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      widget.role,
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _editProfile,
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.white,
                      size: 17,
                    ),
                    label: const Text(
                      'Edit profile',
                      style: TextStyle(color: AppColors.white),
                    ),
                  ),
                ],
              ),
            ),

            _sectionTitle('Account'),
            _menuTile(
              icon: Icons.person_outline,
              title: 'Personal information',
              subtitle: 'Manage your name and email',
              onTap: _editProfile,
            ),
            _menuTile(
              icon: Icons.badge_outlined,
              title: 'Account type',
              subtitle: widget.role,
              iconColor: AppColors.green,
              onTap: () => _showMessage(
                'Your account type is set during role selection.',
              ),
            ),

            _sectionTitle(
              _isHotel ? 'Food Partner Tools' : 'Community Tools',
            ),
            if (_isHotel) ...[
              _menuTile(
                icon: Icons.add_circle_outline,
                title: 'Post a donation',
                subtitle: 'Share your surplus food',
                onTap: () => _showMessage(
                  'Open the Post Food tab to create a donation.',
                ),
              ),
              _menuTile(
                icon: Icons.inventory_2_outlined,
                title: 'My donations',
                subtitle: 'Manage your listed food',
                onTap: () => _showMessage(
                  'Your donation management screen can be connected here.',
                ),
              ),
            ] else ...[
              _menuTile(
                icon: Icons.search,
                title: 'Discover food',
                subtitle: 'Find available food donations',
                onTap: () => _showMessage(
                  'Open the Discover tab to browse donations.',
                ),
              ),
              _menuTile(
                icon: Icons.volunteer_activism_outlined,
                title: 'My collections',
                subtitle: 'Track food collection activity',
                onTap: () => _showMessage(
                  'Your collection history can be connected here.',
                ),
                iconColor: AppColors.green,
              ),
            ],

            _sectionTitle('Support'),
            _menuTile(
              icon: Icons.help_outline,
              title: 'Help & support',
              subtitle: 'Get help using RePlate',
              onTap: () => showDialog<void>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  backgroundColor: AppColors.cream,
                  title: const Text(
                    'Help & Support',
                    style: TextStyle(color: AppColors.brown),
                  ),
                  content: const Text(
                    'RePlate connects surplus food providers '
                        'with organizations that can collect and distribute it.\n\n'
                        'For assistance, contact your project administrator.',
                    style: TextStyle(color: AppColors.textBrown),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: AppColors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _menuTile(
              icon: Icons.info_outline,
              title: 'About RePlate',
              subtitle: 'Reduce food waste, support communities',
              iconColor: AppColors.green,
              onTap: () => showAboutDialog(
                context: context,
                applicationName: 'RePlate',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Share food. Reduce waste. Help people.',
              ),
            ),

            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => showDialog<bool>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: AppColors.cream,
                    title: const Text(
                      'Log out?',
                      style: TextStyle(color: AppColors.brown),
                    ),
                    content: const Text(
                      'Are you sure you want to leave RePlate?',
                      style: TextStyle(color: AppColors.textBrown),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: () =>
                            Navigator.pop(dialogContext, true),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                ).then((confirmed) {
                  if (confirmed == true && mounted) {
                    _logout();
                  }
                }),
                icon: const Icon(Icons.logout, color: AppColors.orange),
                label: const Text(
                  'Log out',
                  style: TextStyle(
                    color: AppColors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Made with care by RePlate',
                style: TextStyle(
                  color: AppColors.textBrown,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
