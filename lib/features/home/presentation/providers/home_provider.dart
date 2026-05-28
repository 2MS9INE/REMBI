import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../listing/domain/listing.dart';
import '../../data/listing_repository.dart';

// Filter States
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  () => SearchQueryNotifier(),
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void updateState(String value) => state = value;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
      () => SelectedCategoryNotifier(),
    );

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void updateState(String? value) => state = value;
}

final selectedWilayaProvider =
    NotifierProvider<SelectedWilayaNotifier, String?>(
      () => SelectedWilayaNotifier(),
    );

class SelectedWilayaNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void updateState(String? value) => state = value;
}

final sortByProvider = NotifierProvider<SortByNotifier, String>(
  () => SortByNotifier(),
);

class SortByNotifier extends Notifier<String> {
  @override
  String build() => 'newest';
  void updateState(String value) => state = value;
}

// Featured Listings
final featuredListingsProvider =
    AsyncNotifierProvider<FeaturedListingsNotifier, List<Listing>>(
      () => FeaturedListingsNotifier(),
    );

class FeaturedListingsNotifier extends AsyncNotifier<List<Listing>> {
  @override
  FutureOr<List<Listing>> build() async {
    final repo = ref.watch(listingRepositoryProvider);
    return repo.fetchFeaturedListings();
  }
}

// Main Listings
final listingsProvider = AsyncNotifierProvider<ListingsNotifier, List<Listing>>(
  () => ListingsNotifier(),
);

class ListingsNotifier extends AsyncNotifier<List<Listing>> {
  @override
  FutureOr<List<Listing>> build() async {
    // Watch all filters — any change automatically re-runs build()
    final category = ref.watch(selectedCategoryProvider);
    final wilaya = ref.watch(selectedWilayaProvider);
    final sortBy = ref.watch(sortByProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final repo = ref.read(listingRepositoryProvider);

    try {
      final result = await repo.fetchListings(
        category: category,
        wilaya: wilaya,
        sortBy: sortBy,
        searchQuery: searchQuery,
        offset: 0,
        limit: 20,
      );
      debugPrint('LISTINGS SUCCESS: ${result.length} items');
      return result;
    } catch (e, st) {
      debugPrint('LISTINGS BUILD ERROR: $e');
      debugPrint('STACK: $st');
      rethrow;
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError) return;
    final currentList = state.value ?? [];
    state = const AsyncValue.loading();
    try {
      final category = ref.read(selectedCategoryProvider);
      final wilaya = ref.read(selectedWilayaProvider);
      final sortBy = ref.read(sortByProvider);
      final searchQuery = ref.read(searchQueryProvider);
      final repo = ref.read(listingRepositoryProvider);
      final moreListings = await repo.fetchListings(
        category: category,
        wilaya: wilaya,
        sortBy: sortBy,
        searchQuery: searchQuery,
        offset: currentList.length,
        limit: 20,
      );
      state = AsyncValue.data([...currentList, ...moreListings]);
    } catch (e, st) {
      debugPrint('LOAD MORE ERROR: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}
