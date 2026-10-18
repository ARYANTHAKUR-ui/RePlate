
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/services/api_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import 'food_item.dart';

class PostFoodScreen extends StatefulWidget {
  const PostFoodScreen({super.key});

  @override
  State<PostFoodScreen> createState() => _PostFoodScreenState();
}

class _PostFoodScreenState extends State<PostFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _peopleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> _categories = [
    'Meals',
    'Snacks',
    'Bakery',
    'Fruits',
    'Other',
  ];

  String _category = 'Meals';
  int _expiryHours = 6;

  Position? _hotelPosition;
  bool _isGettingLocation = false;
  bool _isPublishing = false;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _captureHotelLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _peopleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _captureHotelLocation() async {
    if (!mounted) return;

    setState(() {
      _isGettingLocation = true;
      _locationError = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _hotelPosition = position;
        _isGettingLocation = false;
        _locationError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pickup GPS location captured!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isGettingLocation = false;
        _locationError = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    }
  }

  Future<void> _publishFood() async {
    if (_isPublishing) return;

    if (!_formKey.currentState!.validate()) return;

    if (_hotelPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _locationError ??
                'Please capture the pickup GPS location before publishing.',
          ),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _captureHotelLocation,
          ),
        ),
      );
      return;
    }

    final peopleCount = int.parse(
      _peopleController.text.trim(),
    );

    final food = FoodItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      peopleCount: peopleCount,
      category: _category,
      providerName: 'My Hotel',
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'No additional details provided.'
          : _descriptionController.text.trim(),
      expiresAt: DateTime.now().add(
        Duration(hours: _expiryHours),
      ),
      latitude: _hotelPosition!.latitude,
      longitude: _hotelPosition!.longitude,
    );

    setState(() {
      _isPublishing = true;
    });

    try {
      // Send the donation to the Node.js API and MongoDB.
      await ApiService.createFood(food);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food donation published successfully!'),
          backgroundColor: AppColors.green,
        ),
      );

      _nameController.clear();
      _peopleController.clear();
      _locationController.clear();
      _descriptionController.clear();

      setState(() {
        _category = 'Meals';
        _expiryHours = 6;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not publish donation: $e',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.orange,
      ),
      filled: true,
      fillColor: AppColors.white,
      labelStyle: const TextStyle(
        color: AppColors.textBrown,
      ),
      hintStyle: const TextStyle(
        color: AppColors.textBrown,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.orange,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    final hasLocation = _hotelPosition != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasLocation
            ? AppColors.lightGreen
            : AppColors.lightOrange,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: hasLocation
              ? AppColors.green
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasLocation
                ? Icons.location_on
                : Icons.location_searching,
            color: hasLocation
                ? AppColors.green
                : AppColors.orange,
            size: 27,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasLocation
                      ? 'Pickup GPS captured'
                      : _isGettingLocation
                      ? 'Detecting your location...'
                      : 'Location unavailable',
                  style: const TextStyle(
                    color: AppColors.brown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasLocation
                      ? 'Lat: ${_hotelPosition!.latitude.toStringAsFixed(5)}, '
                      'Lng: ${_hotelPosition!.longitude.toStringAsFixed(5)}'
                      : _locationError ??
                      'Enable location and try again.',
                  style: const TextStyle(
                    color: AppColors.textBrown,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (_isGettingLocation)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.orange,
              ),
            )
          else
            IconButton(
              tooltip: 'Capture GPS again',
              onPressed: _captureHotelLocation,
              icon: const Icon(
                Icons.refresh,
                color: AppColors.green,
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
          'Post Food Donation',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.orange,
                      Color(0xFFFF884D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      color: AppColors.white,
                      size: 36,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Share surplus food',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Your extra food can make a real difference.',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Food information',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Food name',
                  icon: Icons.restaurant_menu,
                  hint: 'e.g. Vegetable rice meals',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the food name.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _inputDecoration(
                  label: 'Food category',
                  icon: Icons.category_outlined,
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isPublishing
                    ? null
                    : (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _peopleController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration(
                  label: 'Servings available',
                  icon: Icons.people_outline,
                  hint: 'Number of people this food can serve',
                ),
                validator: (value) {
                  final count = int.tryParse(
                    value?.trim() ?? '',
                  );

                  if (count == null || count <= 0) {
                    return 'Enter a valid number of servings.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 25),

              const Text(
                'Pickup information',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Pickup address',
                  icon: Icons.location_on_outlined,
                  hint: 'Street, area, city',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a readable pickup address.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildLocationStatus(),

              const SizedBox(height: 25),

              const Text(
                'Availability duration',
                style: TextStyle(
                  color: AppColors.brown,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Pickup should happen within $_expiryHours hour(s).',
                style: const TextStyle(
                  color: AppColors.textBrown,
                ),
              ),

              Slider(
                value: _expiryHours.toDouble(),
                min: 1,
                max: 24,
                divisions: 23,
                activeColor: AppColors.orange,
                inactiveColor: AppColors.lightOrange,
                label: '$_expiryHours hours',
                onChanged: _isPublishing
                    ? null
                    : (value) {
                  setState(() {
                    _expiryHours = value.round();
                  });
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                  label: 'Additional details (optional)',
                  icon: Icons.notes,
                  hint: 'Preparation time, storage, or pickup notes',
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isGettingLocation || _isPublishing)
                      ? null
                      : _publishFood,
                  icon: _isPublishing
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                      : const Icon(Icons.volunteer_activism),
                  label: Text(
                    _isPublishing
                        ? 'Publishing Donation...'
                        : 'Publish Food Donation',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.lightOrange,
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Only list food that can be safely collected. '
                    'The availability duration is not a food-safety certification.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textBrown,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
