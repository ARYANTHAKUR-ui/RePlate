
class FoodItem {
  final String id;
  final String name;
  final int peopleCount;
  final String category;
  final String providerName;
  final String location;
  final String description;
  final DateTime expiresAt;
  final double? latitude;
  final double? longitude;

  const FoodItem({
    required this.id,
    required this.name,
    required this.peopleCount,
    required this.category,
    required this.providerName,
    required this.location,
    required this.description,
    required this.expiresAt,
    this.latitude,
    this.longitude,
  });

  // Convert a donation received from the backend into a FoodItem.
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      peopleCount: (json['peopleCount'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? 'Other',
      providerName: json['providerName'] as String? ?? '',
      location: json['location'] as String? ?? '',
      description: json['description'] as String? ?? '',
      expiresAt: DateTime.tryParse(
        json['expiresAt']?.toString() ?? '',
      ) ??
          DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  // Convert a FoodItem into JSON when needed.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'peopleCount': peopleCount,
      'category': category,
      'providerName': providerName,
      'location': location,
      'description': description,
      'expiresAt': expiresAt.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  bool get isExpired => !expiresAt.isAfter(DateTime.now());

  String get expiryLabel {
    final difference = expiresAt.difference(DateTime.now());

    if (difference.isNegative || difference.inSeconds == 0) {
      return 'Expired';
    }

    if (difference.inDays >= 1) {
      return '${difference.inDays}d ${difference.inHours % 24}h left';
    }

    if (difference.inHours >= 1) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m left';
    }

    return '${difference.inMinutes < 1 ? 1 : difference.inMinutes}m left';
  }
}
