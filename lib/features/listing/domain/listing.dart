class Listing {
  final String id;
  final String farmerId;
  final String title;
  final String description;
  final String category;
  final String? subcategory;
  final Map<String, dynamic> dynamicFields;
  final double? price;
  final bool isNegotiable;
  final String wilaya;
  final String status;
  final int viewCount;
  final bool isFeatured;
  final DateTime expiresAt;
  final DateTime createdAt;
  final List<String> photoUrls;
  final String? sellerName;
  final String? sellerPhotoUrl;
  final double? sellerRating;
  final bool isVerified;

  Listing({
    required this.id,
    required this.farmerId,
    required this.title,
    required this.description,
    required this.category,
    this.subcategory,
    required this.dynamicFields,
    this.price,
    required this.isNegotiable,
    required this.wilaya,
    required this.status,
    required this.viewCount,
    required this.isFeatured,
    required this.expiresAt,
    required this.createdAt,
    required this.photoUrls,
    this.sellerName,
    this.sellerPhotoUrl,
    this.sellerRating,
    required this.isVerified,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    // Extract photos from joined listing_photos table
    final photos =
        (json['listing_photos'] as List<dynamic>?)
            ?.map((e) => e['photo_url'] as String)
            .toList() ??
        [];

    return Listing(
      id: json['id'] as String,
      farmerId: json['farmer_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      dynamicFields: (json['dynamic_fields'] as Map<String, dynamic>?) ?? {},
      price: (json['price'] as num?)?.toDouble(),
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      wilaya: json['wilaya'] as String,
      status: json['status'] as String? ?? 'available',
      viewCount: json['view_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      photoUrls: photos,
      sellerName: json['users']?['full_name'] as String?,
      sellerPhotoUrl: json['users']?['profile_photo_url'] as String?,
      sellerRating: null,
      isVerified: json['users']?['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'title': title,
      'description': description,
      'category': category,
      'subcategory': subcategory,
      'dynamic_fields': dynamicFields,
      'price': price,
      'is_negotiable': isNegotiable,
      'wilaya': wilaya,
      'status': status,
      'view_count': viewCount,
      'is_featured': isFeatured,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'photo_urls': photoUrls,
      // Profiles are read-only joined fields
    };
  }
}
