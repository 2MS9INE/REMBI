import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';

// ── Platform Stats ────────────────────────────────────────────────────────────

final platformStatsProvider = FutureProvider.autoDispose<PlatformStats>((ref) async {
  return ref.read(adminRepositoryProvider).fetchPlatformStats();
});

// ── Pending Verifications ─────────────────────────────────────────────────────

final pendingVerificationsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref.read(adminRepositoryProvider).fetchPendingVerifications();
});

// ── Pending Reports ───────────────────────────────────────────────────────────

final pendingReportsProvider = FutureProvider.autoDispose<List<Report>>((ref) async {
  return ref.read(adminRepositoryProvider).fetchPendingReports();
});

// ── Admin Listings (paginated + search) ──────────────────────────────────────

class AdminListingsNotifier extends Notifier<List<AdminListing>> {
  int _page = 0;
  bool _hasMore = true;
  String _query = '';

  @override
  List<AdminListing> build() {
    return [];
  }

  Future<void> load({bool reset = false}) async {
    if (reset) {
      _page = 0;
      _hasMore = true;
      state = [];
    }
    if (!_hasMore) return;
    
    final results = await ref
        .read(adminRepositoryProvider)
        .fetchAllListings(page: _page);
        
    final filtered = _query.isEmpty
        ? results
        : results
            .where((l) =>
                l.title.toLowerCase().contains(_query.toLowerCase()) ||
                (l.sellerName ?? '').toLowerCase().contains(_query.toLowerCase()))
            .toList();
            
    if (results.length < 20) _hasMore = false;
    _page++;
    state = reset ? filtered : [...state, ...filtered];
  }

  void setQuery(String q) {
    _query = q;
    load(reset: true);
  }
}

final adminListingsProvider =
    NotifierProvider<AdminListingsNotifier, List<AdminListing>>(
        () => AdminListingsNotifier());
