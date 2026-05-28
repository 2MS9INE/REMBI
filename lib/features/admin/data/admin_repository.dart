import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Domain Models ────────────────────────────────────────────────────────────

class Report {
  final String id;
  final String listingId;
  final String listingTitle;
  final String farmerName;
  final String reason;
  final String status;
  final DateTime createdAt;

  const Report({
    required this.id,
    required this.listingId,
    required this.listingTitle,
    required this.farmerName,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Report.fromJson(Map<String, dynamic> j) {
    final listingData = j['listings'] as Map<String, dynamic>?;
    return Report(
      id: j['id'] as String,
      listingId: j['listing_id'] as String,
      listingTitle: listingData?['title'] as String? ?? '—',
      farmerName:
          (listingData?['users'] as Map<String, dynamic>?)?['full_name']
              as String? ??
          '—',
      reason: j['reason'] as String,
      status: j['status'] as String,
      createdAt: DateTime.parse(j['created_at'] as String),
    );
  }
}

class WilayaStat {
  final String wilaya;
  final int count;
  const WilayaStat({required this.wilaya, required this.count});
}

class DailyStat {
  final String date;
  final int count;
  const DailyStat({required this.date, required this.count});
}

class PlatformStats {
  final int totalFarmers;
  final int totalListings;
  final Map<String, int> listingsPerCategory;
  final List<WilayaStat> topWilayas;
  final List<DailyStat> dailyNewListings;
  final int pendingReports;

  const PlatformStats({
    required this.totalFarmers,
    required this.totalListings,
    required this.listingsPerCategory,
    required this.topWilayas,
    required this.dailyNewListings,
    required this.pendingReports,
  });
}

// Simple listing model used only in admin listing manager
class AdminListing {
  final String id;
  final String title;
  final String category;
  final String wilaya;
  final String status;
  final bool isFeatured;
  final List<String> photoUrls;
  final String? sellerName;

  const AdminListing({
    required this.id,
    required this.title,
    required this.category,
    required this.wilaya,
    required this.status,
    required this.isFeatured,
    required this.photoUrls,
    this.sellerName,
  });

  factory AdminListing.fromJson(Map<String, dynamic> j) {
    final photos =
        (j['listing_photos'] as List? ?? []).cast<Map<String, dynamic>>()..sort(
          (a, b) => (a['display_order'] as int? ?? 0).compareTo(
            b['display_order'] as int? ?? 0,
          ),
        );
    return AdminListing(
      id: j['id'] as String,
      title: j['title'] as String? ?? '—',
      category: j['category'] as String? ?? '',
      wilaya: j['wilaya'] as String? ?? '',
      status: j['status'] as String? ?? 'available',
      isFeatured: j['is_featured'] as bool? ?? false,
      photoUrls: photos.map((p) => p['photo_url'] as String).toList(),
      sellerName:
          (j['users'] as Map<String, dynamic>?)?['full_name'] as String?,
    );
  }
}

// ── Repository ───────────────────────────────────────────────────────────────

class AdminRepository {
  final SupabaseClient _client;
  AdminRepository(this._client);

  // ── Verifications ──────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> fetchPendingVerifications() async {
    final data = await _client
        .from('users')
        .select('id, full_name, wilaya, phone, created_at, profile_photo_url')
        .eq('verification_requested', true)
        .eq('is_verified', false);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> approveVerification(String userId) async {
    await _client
        .from('users')
        .update({'is_verified': true, 'verification_requested': false})
        .eq('id', userId);
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': 'تم التحقق من حسابك ✅',
        'message': 'تهانينا! تم التحقق من حسابك على منصة رمبي.',
        'is_read': false,
      });
    } catch (_) {}
  }

  Future<void> rejectVerification(String userId) async {
    await _client
        .from('users')
        .update({'verification_requested': false})
        .eq('id', userId);
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': 'طلب التحقق مرفوض',
        'message':
            'نأسف، تم رفض طلب التحقق من حسابك. يمكنك إعادة المحاولة لاحقاً.',
        'is_read': false,
      });
    } catch (_) {}
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  Future<List<Report>> fetchPendingReports() async {
    final data = await _client
        .from('reports')
        .select(
          '*, listings!reports_listing_id_fkey(title, users!listings_farmer_id_fkey(full_name))',
        )
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return (data as List)
        .map((j) => Report.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> dismissReport(String reportId) async {
    await _client
        .from('reports')
        .update({'status': 'resolved'})
        .eq('id', reportId);
  }

  Future<void> removeListingFromReport(
    String reportId,
    String listingId,
  ) async {
    // 1. Delete photos first — no CASCADE on FK so this must come before listing delete
    await _client.from('listing_photos').delete().eq('listing_id', listingId);

    // 2. Resolve ALL reports pointing to this listing (not just the one clicked)
    await _client
        .from('reports')
        .update({'status': 'resolved'})
        .eq('listing_id', listingId);

    // 3. Now safe to delete the listing
    await _client.from('listings').delete().eq('id', listingId);
  }

  Future<void> warnFarmer(String listingId, String message) async {
    try {
      final listing = await _client
          .from('listings')
          .select('farmer_id')
          .eq('id', listingId)
          .maybeSingle(); // ← maybeSingle instead of single — won't throw if no row

      final farmerId = listing?['farmer_id'] as String?;
      if (farmerId == null) return;

      await _client.from('notifications').insert({
        'user_id': farmerId,
        'title': 'تحذير من الإدارة ⚠️',
        'message': message,
        'is_read': false,
      });
    } catch (e) {
      rethrow; // let the UI catch and show the error
    }
  }
  // ── Platform Stats ─────────────────────────────────────────────────────────

  Future<PlatformStats> fetchPlatformStats() async {
    // Farmers count via simple select + length
    final farmersRows = await _client
        .from('users')
        .select('id')
        .eq('role', 'farmer');
    final totalFarmers = (farmersRows as List).length;

    final listingsRows = await _client
        .from('listings')
        .select('id, category, wilaya, created_at');
    final allListings = listingsRows as List;
    final totalListings = allListings.length;

    // Per-category count
    final Map<String, int> listingsPerCategory = {};
    for (final row in allListings) {
      final cat =
          (row as Map<String, dynamic>)['category'] as String? ?? 'Other';
      listingsPerCategory[cat] = (listingsPerCategory[cat] ?? 0) + 1;
    }

    // Top wilayas
    final Map<String, int> wilayaCounts = {};
    for (final row in allListings) {
      final w = (row as Map<String, dynamic>)['wilaya'] as String? ?? '';
      if (w.isNotEmpty) wilayaCounts[w] = (wilayaCounts[w] ?? 0) + 1;
    }
    final sortedWilayas = wilayaCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sortedWilayas
        .take(5)
        .map((e) => WilayaStat(wilaya: e.key, count: e.value))
        .toList();

    // Daily new listings (last 7 days)
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final Map<String, int> dailyCounts = {};
    for (final row in allListings) {
      final createdAt = (row as Map<String, dynamic>)['created_at'] as String?;
      if (createdAt != null) {
        final dt = DateTime.tryParse(createdAt);
        if (dt != null && dt.isAfter(cutoff)) {
          final date = createdAt.substring(0, 10);
          dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
        }
      }
    }
    final dailyStats =
        dailyCounts.entries
            .map((e) => DailyStat(date: e.key, count: e.value))
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    // Pending reports
    final reportsRows = await _client
        .from('reports')
        .select('id')
        .eq('status', 'pending');
    final pendingReports = (reportsRows as List).length;

    return PlatformStats(
      totalFarmers: totalFarmers,
      totalListings: totalListings,
      listingsPerCategory: listingsPerCategory,
      topWilayas: top5,
      dailyNewListings: dailyStats,
      pendingReports: pendingReports,
    );
  }

  // ── Listings management ────────────────────────────────────────────────────

  Future<List<AdminListing>> fetchAllListings({
    int page = 0,
    int limit = 20,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;
    final data = await _client
        .from('listings')
        .select('*, listing_photos(photo_url, display_order), users(full_name)')
        .order('created_at', ascending: false)
        .range(from, to);
    return (data as List)
        .map((j) => AdminListing.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> pinListing(String listingId) async {
    final resp = await _client
        .from('listings')
        .select('id')
        .eq('is_featured', true);
    final count = (resp as List).length;
    if (count >= 5) throw Exception('pin_limit_reached');
    await _client
        .from('listings')
        .update({'is_featured': true})
        .eq('id', listingId);
  }

  Future<void> unpinListing(String listingId) async {
    await _client
        .from('listings')
        .update({'is_featured': false})
        .eq('id', listingId);
  }

  Future<void> deleteReview(String reviewId) async {
    await _client.from('reviews').delete().eq('id', reviewId);
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(Supabase.instance.client),
);
