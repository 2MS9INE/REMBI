import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/seller_profile.dart';
import '../../domain/review.dart';
import '../../data/seller_repository.dart';
import '../../../listing/domain/listing.dart';

final sellerProfileProvider = FutureProvider.family<SellerProfile, String>((ref, id) async {
  return ref.watch(sellerRepositoryProvider).fetchSellerById(id);
});

final sellerListingsProvider = FutureProvider.family<List<Listing>, String>((ref, id) async {
  return ref.watch(sellerRepositoryProvider).fetchSellerListings(id);
});

final sellerReviewsProvider = FutureProvider.family<List<Review>, String>((ref, id) async {
  return ref.watch(sellerRepositoryProvider).fetchSellerReviews(id);
});
