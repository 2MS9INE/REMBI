import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/seller_profile.dart';
import '../domain/review.dart';
import '../../listing/domain/listing.dart';

final sellerRepositoryProvider = Provider(
  (ref) => SellerRepository(Supabase.instance.client),
);

class SellerRepository {
  final SupabaseClient _supabase;
  SellerRepository(this._supabase);

  Future<SellerProfile> fetchSellerById(String sellerId) async {
    try {
      final data = await _supabase
          .from('users')
          .select('*')
          .eq('id', sellerId)
          .single();

      final countResponse = await _supabase
          .from('reviews')
          .select('id')
          .eq('seller_id', sellerId);

      final int totalReviews = (countResponse as List).length;

      final ratingResponse = await _supabase
          .from('reviews')
          .select('rating')
          .eq('seller_id', sellerId);

      final ratings = (ratingResponse as List)
          .map((r) => (r['rating'] as num).toDouble())
          .toList();
      final avgRating = ratings.isEmpty
          ? 0.0
          : ratings.reduce((a, b) => a + b) / ratings.length;

      data['total_reviews'] = totalReviews;
      data['average_rating'] = avgRating;

      return SellerProfile.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch seller profile: $e');
    }
  }

  Future<List<Listing>> fetchSellerListings(String sellerId) async {
    try {
      final data = await _supabase
          .from('listings')
          .select(
            '*, users!listings_farmer_id_fkey(full_name, profile_photo_url, is_verified), listing_photos(photo_url)',
          )
          .eq('farmer_id', sellerId)
          .eq('status', 'available')
          .gt('expires_at', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);
      return data.map((json) => Listing.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch seller listings: $e');
    }
  }

  Future<List<Review>> fetchSellerReviews(String sellerId) async {
    try {
      final data = await _supabase
          .from('reviews')
          .select('*')
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch seller reviews: $e');
    }
  }

  Future<void> submitReview({
    required String sellerId,
    required String reviewerName,
    required double rating,
    String? comment,
  }) async {
    try {
      await _supabase.from('reviews').insert({
        'seller_id': sellerId,
        'reviewer_name': reviewerName,
        'rating': rating.toInt(),
        'comment': comment,
      });
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<void> submitReport(String listingId, String reason) async {
    try {
      await _supabase.from('reports').insert({
        'listing_id': listingId,
        'reason': reason,
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }
}
