class Review {
  final String id;
  final String sellerId;
  final String reviewerName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.sellerId,
    required this.reviewerName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    // If reviewer_name is null, we can try to get it from profiles join or fallback
    final joinedProfile = json['profiles'] as Map<String, dynamic>?;
    final fallbackName =
        joinedProfile?['full_name'] as String? ?? 'Anonymous User';

    return Review(
      id: json['id'] as String,
      sellerId: json['seller_id'] as String,
      reviewerName: json['reviewer_name'] as String? ?? fallbackName,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
