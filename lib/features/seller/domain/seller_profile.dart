class SellerProfile {
  final String id;
  final String fullName;
  final String? phone;
  final String? whatsapp;
  final String wilaya;
  final String? profilePhotoUrl;
  final bool isVerified;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;

  SellerProfile({
    required this.id,
    required this.fullName,
    this.phone,
    this.whatsapp,
    required this.wilaya,
    this.profilePhotoUrl,
    required this.isVerified,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
  });

  factory SellerProfile.fromJson(Map<String, dynamic> json) {
    return SellerProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown Seller',
      phone: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      wilaya: json['wilaya'] as String? ?? 'Unknown Location',
      profilePhotoUrl: json['profile_photo_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
