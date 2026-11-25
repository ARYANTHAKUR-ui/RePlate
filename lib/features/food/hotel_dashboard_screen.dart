
import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'food_item.dart';
import 'post_food_screen.dart';

class HotelDashboardScreen extends StatefulWidget {
  const HotelDashboardScreen({super.key});

  @override
  State<HotelDashboardScreen> createState() =>
      _HotelDashboardScreenState();
}

class _HotelDashboardScreenState extends State<HotelDashboardScreen> {
  List<FoodItem> _foods = [];

  bool _loading = true;
  bool _openingUpload = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final foods = await ApiService.getMyFoods();

      if (!mounted) return;

      setState(() {
        _foods = foods;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // Open the upload page and refresh only after successful publishing.
  Future<void> _openPostFoodScreen() async {
    if (_openingUpload) return;

    setState(() => _openingUpload = true);

    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute<bool>(
          builder: (_) => const PostFoodScreen(),
        ),
      );

      if (!mounted) return;

      if (result == true) {
        await _loadFoods();
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open upload screen: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _openingUpload = false);
      }
    }
  }

  bool _isExpired(FoodItem food) => food.isExpired;

  String _expiryText(FoodItem food) {
    final difference = food.expiresAt.difference(DateTime.now());

    if (difference.inSeconds <= 0) return 'Expired';
    if (difference.inDays >= 1) {
      return 'Expires in ${difference.inDays} day(s)';
    }
    if (difference.inHours >= 1) {
      return 'Expires in ${difference.inHours} hour(s)';
    }
    if (difference.inMinutes >= 1) {
      return 'Expires in ${difference.inMinutes} minute(s)';
    }

    return 'Expires soon';
  }

  Future<void> _deleteFood(FoodItem food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cream,
        title: const Text(
          'Delete donation?',
          style: TextStyle(color: AppColors.brown),
        ),
        content: Text(
          'Are you sure you want to delete "${food.name}"?',
          style: const TextStyle(color: AppColors.textBrown),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiService.deleteFood(food.id);

      if (!mounted) return;

      setState(() {
        _foods.removeWhere((item) => item.id == food.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donation deleted successfully.'),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete donation: '
                '${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _statCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color background,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 25),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: const TextStyle(
                color: AppColors.brown,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textBrown,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textBrown),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textBrown,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foodCard(FoodItem food) {
    final expired = _isExpired(food);

    return Card(
      color: AppColors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 54,
                  width: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.lightOrange,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.fastfood_rounded,
                    color: AppColors.orange,
                    size: 29,
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
                          color: AppColors.brown,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        food.category,
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
                    color: expired
                        ? Colors.red.shade50
                        : AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    expired ? 'Expired' : 'Available',
                    style: TextStyle(
                      color: expired
                          ? Colors.red.shade700
                          : AppColors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.border),
            _detailRow(
              Icons.people_outline_rounded,
              'Serves ${food.peopleCount} people',
            ),
            _detailRow(
              Icons.location_on_outlined,
              food.location.isEmpty
                  ? 'Pickup location not specified'
                  : food.location,
            ),
            _detailRow(
              Icons.access_time_rounded,
              _expiryText(food),
            ),
            if (food.description.trim().isNotEmpty)
              _detailRow(
                Icons.notes_rounded,
                food.description,
              ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _deleteFood(food),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                label: const Text(
                  'Delete donation',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _openingUpload ? null : _openPostFoodScreen,
        icon: _openingUpload
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        )
            : const Icon(Icons.add_circle_outline_rounded),
        label: const Text(
          'Upload New Food',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Column(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: const BoxDecoration(
              color: AppColors.lightOrange,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rice_bowl_rounded,
              color: AppColors.orange,
              size: 44,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No donations yet',
            style: TextStyle(
              color: AppColors.brown,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Upload your first donation to share surplus food.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textBrown),
          ),
          const SizedBox(height: 18),
          _uploadButton(),
        ],
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 52,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 14),
            const Text(
              'Could not load donations',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textBrown),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadFoods,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orange,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount =
        _foods.where((food) => !_isExpired(food)).length;
    final expiredCount =
        _foods.where((food) => _isExpired(food)).length;

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.brown,
        elevation: 0,
        title: const Text(
          'Hotel Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh donations',
            onPressed: _loading ? null : _loadFoods,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.orange,
          onRefresh: _loadFoods,
          child: _loading
              ? const Center(
            child: CircularProgressIndicator(
              color: AppColors.orange,
            ),
          )
              : _error != null
              ? ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height:
                MediaQuery.of(context).size.height * 0.6,
                child: _errorState(),
              ),
            ],
          )
              : ListView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20, 12, 20, 30,
            ),
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage your food donations and help '
                    'reduce food waste.',
                style: TextStyle(
                  color: AppColors.textBrown,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              _uploadButton(),

              const SizedBox(height: 24),

              const Text(
                'Donation Overview',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _statCard(
                    title: 'Total',
                    count: _foods.length,
                    icon: Icons.volunteer_activism_rounded,
                    color: AppColors.orange,
                    background: AppColors.lightOrange,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    title: 'Active',
                    count: activeCount,
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.green,
                    background: AppColors.lightGreen,
                  ),
                  const SizedBox(width: 10),
                  _statCard(
                    title: 'Expired',
                    count: expiredCount,
                    icon: Icons.access_time_rounded,
                    color: Colors.redAccent,
                    background: const Color(0xFFFFE9E6),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Your Donations',
                      style: TextStyle(
                        color: AppColors.brown,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${_foods.length} total',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if (_foods.isEmpty)
                _emptyState()
              else
                ..._foods.map(_foodCard),
            ],
          ),
        ),
      ),
    );
  }
}
