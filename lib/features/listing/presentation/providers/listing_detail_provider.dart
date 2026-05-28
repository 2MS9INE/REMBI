import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/listing.dart';
import '../../data/listing_detail_repository.dart';

final listingDetailProvider = FutureProvider.family<Listing, String>((
  ref,
  id,
) async {
  final repo = ref.watch(listingDetailRepositoryProvider);
  unawaited(repo.incrementViewCount(id));
  return repo.fetchListingById(id);
});
