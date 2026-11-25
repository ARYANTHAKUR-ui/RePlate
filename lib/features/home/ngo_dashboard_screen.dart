
import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import '../food/food_item.dart';
import 'home_screen.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen> {
  int _selectedIndex = 1;
  List<FoodItem> _acceptedFoods = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAcceptedFoods();
  }

  Future<void> _loadAcceptedFoods() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final foods = await ApiService.getAcceptedFoods();

      if (!mounted) return;

      setState(() {
        _acceptedFoods = foods;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  int get _pendingCount =>
      _acceptedFoods.where((food) => food.status == 'claimed').length;

  int get _collectedCount =>
      _acceptedFoods.where((food) => food.status == 'collected').length;

  int get _collectedPortions => _acceptedFoods
      .where((food) => food.status == 'collected')
      .fold<int>(0, (total, food) => total + food.peopleCount);

  Future<void> _markAsCollected(FoodItem food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm collection'),
        content: Text(
          'Have you collected "${food.name}" from '
              '${food.providerName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes, collected'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await ApiService.markFoodCollected(food.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation marked as collected!'),
          backgroundColor: AppColors.green,
        ),
      );

      await _loadAcceptedFoods();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update donation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            const HomeScreen(role: 'NGO / Organization'),
            _buildMyDonations(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.lightOrange,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);

          if (index == 1) {
            _loadAcceptedFoods();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'My Donations',
          ),
        ],
      ),
    );
  }

  Widget _buildMyDonations() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
          decoration: const BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RePlate NGO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'My Donations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Every meal shared makes a difference.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _loadAcceptedFoods,
                tooltip: 'Refresh donations',
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? _buildError()
              : RefreshIndicator(
            onRefresh: _loadAcceptedFoods,
            child: _buildDonationContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 70),
        const Icon(
          Icons.cloud_off_outlined,
          size: 54,
          color: AppColors.brown,
        ),
        const SizedBox(height: 16),
        const Text(
          'Could not load your donations',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textBrown),
        ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton(
            onPressed: _loadAcceptedFoods,
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationContent() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Accepted',
                '${_acceptedFoods.length}',
                Icons.volunteer_activism_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                'Pending',
                '$_pendingCount',
                Icons.pending_actions,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                'Collected',
                '$_collectedCount',
                Icons.check_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.restaurant,
                size: 32,
                color: AppColors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'People served',
                      style: TextStyle(color: AppColors.textBrown),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_collectedPortions portions collected',
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Your accepted food',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.brown,
          ),
        ),
        const SizedBox(height: 12),
        if (_acceptedFoods.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 36,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  size: 52,
                  color: AppColors.orange,
                ),
                SizedBox(height: 12),
                Text(
                  'No accepted donations yet',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brown,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Open Discover to find and accept nearby food donations.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textBrown),
                ),
              ],
            ),
          )
        else
          ..._acceptedFoods.map(_donationCard),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.orange, size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textBrown,
            ),
          ),
        ],
      ),
    );
  }

  Widget _donationCard(FoodItem food) {
    final collected = food.status == 'collected';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.lightOrange,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: AppColors.orange,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From ${food.providerName}',
                      style: const TextStyle(
                        color: AppColors.textBrown,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${food.peopleCount} portions • ${food.category}',
                      style: const TextStyle(
                        color: AppColors.textBrown,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: collected
                      ? AppColors.lightGreen
                      : AppColors.lightOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  collected ? 'Collected' : 'Pending',
                  style: TextStyle(
                    color: collected
                        ? AppColors.green
                        : AppColors.brown,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.orange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  food.location,
                  style: const TextStyle(color: AppColors.textBrown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 18,
                color: AppColors.orange,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  food.expiryLabel,
                  style: const TextStyle(color: AppColors.textBrown),
                ),
              ),
            ],
          ),
          if (food.description.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              food.description,
              style: const TextStyle(color: AppColors.textBrown),
            ),
          ],
          if (!collected) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _markAsCollected(food),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark as collected'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
