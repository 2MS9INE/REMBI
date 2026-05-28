import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../listing/domain/listing.dart';

final listingRepositoryProvider = Provider(
  (ref) => ListingRepository(Supabase.instance.client),
);

class ListingRepository {
  final SupabaseClient _supabase;

  ListingRepository(this._supabase);

  Future<List<Listing>> fetchListings({
    String? category,
    String? wilaya,
    String? sortBy,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      dynamic query = _supabase
          .from('listings')
          // ✅
          .select(
            '*, users!listings_farmer_id_fkey(full_name, profile_photo_url, is_verified), listing_photos(photo_url, display_order)',
          )
          .eq('status', 'available')
          .gt('expires_at', DateTime.now().toIso8601String());

      if (category != null && category != 'all') {
        query = query.eq('category', category);
      }

      if (wilaya != null && wilaya != 'All wilayas') {
        query = query.eq('wilaya', wilaya);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        // ILIKE for case-insensitive search on title or description
        query = query.or(
          'title.ilike.%${searchQuery.trim()}%,description.ilike.%${searchQuery.trim()}%',
        );
      }

      // Sorting
      switch (sortBy) {
        case 'price_asc':
          query = query.order('price', ascending: true);
          break;
        case 'price_desc':
          query = query.order('price', ascending: false);
          break;
        case 'most_reviewed':
          query = query.order('view_count', ascending: false);
          break;
        case 'newest':
        default:
          query = query.order('created_at', ascending: false);
          break;
      }

      final data = await query.range(offset, offset + limit - 1);
      return (data as List<dynamic>)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch listings: $e');
    }
  }

  Future<List<Listing>> fetchFeaturedListings() async {
    try {
      final cutoff = DateTime.now()
          .subtract(const Duration(hours: 48))
          .toIso8601String();

      final data = await _supabase
          .from('listings')
          .select(
            '*, users!listings_farmer_id_fkey(full_name, profile_photo_url, is_verified), listing_photos(photo_url, display_order)',
          )
          .eq('status', 'available')
          .gt('expires_at', DateTime.now().toIso8601String())
          .gt('created_at', cutoff) // ← only last 48 hours
          .order('created_at', ascending: false)
          .limit(8);

      debugPrint('FEATURED FETCHED: ${data.length} items');
      return (data as List<dynamic>)
          .map((json) => Listing.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('FEATURED ERROR: $e');
      throw Exception('Failed to fetch featured listings: $e');
    }
  }

  Future<void> incrementViewCount(String listingId) async {
    // using direct RPC or Update if permissions allow
    try {
      // In a real scenario we might use RPC for atomicity: _supabase.rpc('increment_view_count', params: {'listing_id': listingId})
      // Here we will just fetch, increment and update. Wait, RPC is better if it exists.
      // Assuming RPC doesn't exist yet, we can do a naive update or just RPC if we had it.
      // Since we can't change Phase 1 schema, we will do a naive increment for now.
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
