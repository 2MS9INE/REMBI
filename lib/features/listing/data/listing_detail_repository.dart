import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/listing.dart';
import 'package:flutter/foundation.dart';

final listingDetailRepositoryProvider = Provider(
  (ref) => ListingDetailRepository(Supabase.instance.client),
);

class ListingDetailRepository {
  final SupabaseClient _supabase;

  ListingDetailRepository(this._supabase);

  Future<Listing> fetchListingById(String listingId) async {
    final data = await _supabase
        .from('listings')
        .select(
          '*, users!listings_farmer_id_fkey(full_name, profile_photo_url, is_verified), listing_photos(photo_url)',
        )
        .eq('id', listingId)
        .single();

    debugPrint('RAW DATA: $data');
    return Listing.fromJson(data);
  }

  Future<void> incrementViewCount(String listingId) async {
    try {
      // First fetch the current count to increment. A true RPC is better, but this suffices for the scope.
      final current = await _supabase
          .from('listings')
          .select('view_count')
          .eq('id', listingId)
          .single();
      final currentCount = current['view_count'] as int? ?? 0;
      await _supabase
          .from('listings')
          .update({'view_count': currentCount + 1})
          .eq('id', listingId);
    } catch (e) {
      debugPrint('Warning: Failed to increment view count: $e');
    }
  }
}
