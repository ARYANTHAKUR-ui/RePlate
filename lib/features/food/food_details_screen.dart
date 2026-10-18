
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';

class FoodDetailsScreen extends StatefulWidget {
  final String foodName;
  final String category;
  final int quantity;
  final String providerName;
  final String location;
  final String pickupTime;
  final String description;
  final String role;
  final IconData foodIcon;

  // GPS coordinates of the pickup location.
  final double? latitude;
  final double? longitude;

  const FoodDetailsScreen({
    super.key,
    required this.foodName,
    required this.category,
    required this.quantity,
    required this.providerName,
    required this.location,
    required this.pickupTime,
    required this.description,
    this.role = 'NGO / Organization',
    this.foodIcon = Icons.restaurant,
    this.latitude,
    this.longitude,
  });

  @override
  State<FoodDetailsScreen> createState() =>
      _FoodDetailsScreenState();
}

class _FoodDetailsScreenState
    extends State<FoodDetailsScreen> {
  bool _isClaimed = false;
  bool _isOpeningMaps = false;

  bool get _isHotel =>
      widget.role == 'Hotel / Restaurant';

  Future<void> _openGoogleMaps() async {
    final lat = widget.latitude;
    final lng = widget.longitude;

    if (lat == null ||
        lng == null ||
        !lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pickup GPS location is unavailable.',
          ),
        ),
      );
      return;
    }

    setState(() => _isOpeningMaps = true);

    final uri = Uri.https(
      'www.google.com',
      '/maps/dir/',
      {
        'api': '1',
        'destination': '$lat,$lng',
        'travelmode': 'driving',
      },
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!mounted) return;

      if (!opened) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open the map. Please try again.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Google Maps: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isOpeningMaps = false);
      }
    }
  }

  Future<void> _claimFood() async {
    if (_isClaimed) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cream,
          title: const Text(
            'Claim this food?',
            style: TextStyle(
              color: AppColors.brown,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Confirm that your organization wants to '
                'collect "${widget.foodName}" from '
                '${widget.providerName}.',
            style: const TextStyle(
              color: AppColors.textBrown,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Confirm claim'),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    setState(() => _isClaimed = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Food claimed in demo mode!',
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color iconColor = AppColors.orange,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textBrown,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: const TextStyle(
                    color: AppColors.brown,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
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
          'Food Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food banner.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.lightOrange,
                      AppColors.cream,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 94,
                      height: 94,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(
                          alpha: 0.85,
                        ),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Icon(
                        widget.foodIcon,
                        size: 52,
                        color: AppColors.orange,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      widget.foodName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.brown,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.category,
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quantity.
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.people_alt_outlined,
                      size: 34,
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Food available for',
                            style: TextStyle(
                              color: AppColors.textBrown,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.quantity} people',
                            style: const TextStyle(
                              color: AppColors.brown,
                              fontSize: 20,
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
                'Donation information',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.storefront_outlined,
                      title: 'Donated by',
                      value: widget.providerName,
                    ),
                    const Divider(color: AppColors.border),
                    _buildInfoRow(
                      icon: Icons.location_on_outlined,
                      title: 'Pickup address',
                      value: widget.location,
                      iconColor: AppColors.green,
                    ),
                    const Divider(color: AppColors.border),
                    _buildInfoRow(
                      icon: Icons.access_time,
                      title: 'Availability',
                      value: widget.pickupTime,
                    ),
                    const Divider(color: AppColors.border),
                    _buildInfoRow(
                      icon: Icons.description_outlined,
                      title: 'Description',
                      value: widget.description,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Google Maps button.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isOpeningMaps
                      ? null
                      : _openGoogleMaps,
                  icon: _isOpeningMaps
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.directions),
                  label: Text(
                    _isOpeningMaps
                        ? 'Opening Maps...'
                        : 'Get Directions in Google Maps',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(
                      color: AppColors.green,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (!_isHotel) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                    _isClaimed ? null : _claimFood,
                    icon: Icon(
                      _isClaimed
                          ? Icons.check_circle
                          : Icons.volunteer_activism,
                    ),
                    label: Text(
                      _isClaimed
                          ? 'Food Claimed'
                          : 'Claim This Food',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor:
                      AppColors.lightGreen,
                      disabledForegroundColor:
                      AppColors.green,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              const Text(
                'Please verify the food condition, quantity, '
                    'and safe pickup arrangements with the donor.',
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
  }
}
