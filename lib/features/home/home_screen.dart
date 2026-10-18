
import 'package:flutter/material.dart';

import '../../core/services/api_service.dart';
import '../../core/services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../food/food_details_screen.dart';
import '../food/food_item.dart';

class HomeScreen extends StatefulWidget {
  final String role;

  const HomeScreen({
    super.key,
    this.role = 'NGO / Organization',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  List<FoodItem> _foods = [];
  String _selectedCategory = 'All';

  double? _latitude;
  double? _longitude;

  bool _loadingLocation = false;
  bool _loadingFoods = true;
  String? _errorMessage;

  final List<String> _categories = const [
    'All',
    'Meals',
    'Snacks',
    'Bakery',
    'Fruits',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch real donations from the backend/MongoDB.
  Future<void> _loadFoods() async {
    if (!mounted) return;

    setState(() {
      _loadingFoods = true;
      _errorMessage = null;
    });

    try {
      final donations = await ApiService.getFoods();

      if (!mounted) return;

      setState(() {
        _foods = donations;
        _loadingFoods = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _loadingFoods = false;
      });
    }
  }

  Future<void> _refresh() async {
    await Future.wait([
      _loadFoods(),
      _getCurrentLocation(),
    ]);
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() => _loadingLocation = true);

    try {
      final position =
      await LocationService.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (_) {
      // Food discovery still works without GPS.
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  double? _distanceTo(FoodItem food) {
    if (_latitude == null ||
        _longitude == null ||
        food.latitude == null ||
        food.longitude == null) {
      return null;
    }

    return LocationService.distanceInKm(
      fromLatitude: _latitude!,
      fromLongitude: _longitude!,
      toLatitude: food.latitude!,
      toLongitude: food.longitude!,
    );
  }

  List<FoodItem> _filteredFoods() {
    final query = _searchController.text.trim().toLowerCase();

    // Exclude expired donations.
    final foods = _foods.where((food) {
      if (food.isExpired) return false;

      final matchesCategory = _selectedCategory == 'All' ||
          food.category.toLowerCase() ==
              _selectedCategory.toLowerCase();

      final matchesSearch = query.isEmpty ||
          food.name.toLowerCase().contains(query) ||
          food.category.toLowerCase().contains(query) ||
          food.providerName.toLowerCase().contains(query) ||
          food.location.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();

    // Sort donations with known distances from nearest to farthest.
    foods.sort((a, b) {
      final distanceA = _distanceTo(a);
      final distanceB = _distanceTo(b);

      if (distanceA == null && distanceB == null) return 0;
      if (distanceA == null) return 1;
      if (distanceB == null) return -1;

      return distanceA.compareTo(distanceB);
    });

    return foods;
  }

  IconData _foodIcon(String category) {
    switch (category.toLowerCase()) {
      case 'meals':
        return Icons.rice_bowl_outlined;
      case 'snacks':
        return Icons.fastfood_outlined;
      case 'bakery':
        return Icons.bakery_dining_outlined;
      case 'fruits':
        return Icons.apple_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foods = _filteredFoods();

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Discover Food'),
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.brown,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadingLocation
                ? null
                : _getCurrentLocation,
            tooltip: 'Refresh GPS',
            icon: _loadingLocation
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.my_location),
          ),
          IconButton(
            onPressed: _loadFoods,
            tooltip: 'Refresh donations',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20, 8, 20, 18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Good Food. Second Chances.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Find surplus food shared by nearby restaurants.',
                    style: TextStyle(
                      color: AppColors.textBrown,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search food or location...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.orange,
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final selected =
                            _selectedCategory == category;

                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: AppColors.lightOrange,
                          backgroundColor: AppColors.white,
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.brown
                                : AppColors.textBrown,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: const BorderSide(
                            color: AppColors.border,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Row(
                children: [
                  const Text(
                    'Available donations',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brown,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${foods.length} found',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _loadingFoods
                  ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.orange,
                ),
              )
                  : _errorMessage != null
                  ? _errorState()
                  : RefreshIndicator(
                color: AppColors.orange,
                onRefresh: _refresh,
                child: foods.isEmpty
                    ? ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 350,
                      child: _emptyState(),
                    ),
                  ],
                )
                    : ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding:
                  const EdgeInsets.fromLTRB(
                    20, 4, 20, 24,
                  ),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    return _foodCard(foods[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 54,
              color: AppColors.orange,
            ),
            const SizedBox(height: 16),
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
              _errorMessage ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textBrown,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _loadFoods,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
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

  Widget _foodCard(FoodItem food) {
    final distance = _distanceTo(food);

    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailsScreen(
                foodName: food.name,
                category: food.category,
                quantity: food.peopleCount,
                providerName: food.providerName,
                location: food.location,
                pickupTime: food.expiryLabel,
                description: food.description,
                role: widget.role,
                latitude: food.latitude,
                longitude: food.longitude,
                foodIcon: _foodIcon(food.category),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.lightOrange,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _foodIcon(food.category),
                  size: 34,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(width: 14),
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
                    const SizedBox(height: 5),
                    Text(
                      food.providerName,
                      style: const TextStyle(
                        color: AppColors.textBrown,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _tag(
                          '${food.peopleCount} people',
                          AppColors.lightGreen,
                          AppColors.green,
                        ),
                        _tag(
                          food.category,
                          AppColors.lightOrange,
                          AppColors.brown,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.green,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            distance == null
                                ? food.location
                                : '${distance.toStringAsFixed(1)} km away',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          food.expiryLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(
      String label,
      Color background,
      Color foreground,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_outlined,
                size: 48,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No donations found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.brown,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'New food donations will appear here. '
                  'Try another category or search term.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: AppColors.textBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
