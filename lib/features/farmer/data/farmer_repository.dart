import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../listing/domain/listing.dart';

final farmerRepositoryProvider = Provider<FarmerRepository>(
  (ref) => FarmerRepository(Supabase.instance.client),
);

class FarmerRepository {
  final SupabaseClient _supabase;
  FarmerRepository(this._supabase);

  Future<List<Listing>> fetchMyListings() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final data = await _supabase
        .from('listings')
        .select(
          '*, listing_photos(photo_url, display_order), users(full_name, profile_photo_url, is_verified, wilaya)',
        )
        .eq('farmer_id', uid)
        .order('created_at', ascending: false);

    return data.map((json) => Listing.fromJson(json)).toList();
  }

  Future<void> deleteListing(String listingId) async {
    await _supabase.from('listings').delete().eq('id', listingId);
  }

  Future<void> toggleListingStatus(String listingId, String newStatus) async {
    await _supabase
        .from('listings')
        .update({'status': newStatus})
        .eq('id', listingId);
  }

  Future<String> createListing({
    required String title,
    String? description,
    required String category,
    required String subcategory,
    Map<String, dynamic>? dynamicFields,
    double? price,
    required bool isNegotiable,
    required String wilaya,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('Not authenticated');

    final response = await _supabase
        .from('listings')
        .insert({
          'farmer_id': uid,
          'title': title,
          'description': description,
          'category': category,
          'subcategory': subcategory,
          'dynamic_fields': dynamicFields ?? {},
          'price': price,
          'is_negotiable': isNegotiable,
          'wilaya': wilaya,
          'status': 'available',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> updateListing({
    required String listingId,
    required String title,
    String? description,
    required String category,
    required String subcategory,
    Map<String, dynamic>? dynamicFields,
    double? price,
    required bool isNegotiable,
    required String wilaya,
  }) async {
    await _supabase
        .from('listings')
        .update({
          'title': title,
          'description': description,
          'category': category,
          'subcategory': subcategory,
          'dynamic_fields': dynamicFields ?? {},
          'price': price,
          'is_negotiable': isNegotiable,
          'wilaya': wilaya,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', listingId);
  }

  Future<void> addListingPhoto(
    String listingId,
    String photoUrl,
    int order,
  ) async {
    await _supabase.from('listing_photos').insert({
      'listing_id': listingId,
      'photo_url': photoUrl,
      'display_order': order,
    });
  }

  Future<void> deleteListingPhotos(String listingId) async {
    await _supabase.from('listing_photos').delete().eq('listing_id', listingId);
  }

  Future<Map<String, dynamic>> fetchListingById(String listingId) async {
    return await _supabase
        .from('listings')
        .select('*, listing_photos(photo_url, display_order)')
        .eq('id', listingId)
        .single();
  }
}
