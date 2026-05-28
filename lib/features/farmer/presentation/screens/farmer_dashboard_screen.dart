import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../listing/domain/listing.dart';
import '../../data/farmer_repository.dart';

final _myListingsProvider = FutureProvider<List<Listing>>((ref) {
  return ref.watch(farmerRepositoryProvider).fetchMyListings();
});

class FarmerDashboardScreen extends ConsumerWidget {
  const FarmerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    // Auth guard -- router handles redirect but guard defensively
    final authAsync = ref.watch(authStateProvider);
    authAsync.whenData((authState) {
      if (authState.session == null) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => context.go('/auth/login'),
        );
      }
    });

    final profileAsync = ref.watch(currentUserProfileProvider);
    final listingsAsync = ref.watch(_myListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.farmerDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () async {
              await ref.read(authRepositoryProvider).logoutFarmer();
              if (context.mounted) context.go('/auth/login');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/farmer/listing/new'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addListing),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_myListingsProvider);
          ref.invalidate(currentUserProfileProvider);
        },
        child: CustomScrollView(
          slivers: [
            // ── Header Card ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: profileAsync.when(
                loading: () => const _ProfileHeaderSkeleton(),
                error: (e, _) => const SizedBox.shrink(),
                data: (profile) => profile == null
                    ? const SizedBox.shrink()
                    : _ProfileHeader(profile: profile, ref: ref),
              ),
            ),

            // ── Stats Row ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: listingsAsync.when(
                loading: () => const SizedBox(height: 80),
                error: (e, _) => const SizedBox.shrink(),
                data: (listings) => _StatsRow(listings: listings, l10n: l10n),
              ),
            ),

            // ── My Listings Header ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  l10n.myListings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ── Listings List ────────────────────────────────────────
            listingsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) =>
                  SliverToBoxAdapter(child: Center(child: Text(e.toString()))),
              data: (listings) {
                if (listings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noListingsYet,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ListingManagementTile(
                      listing: listings[i],
                      l10n: l10n,
                      ref: ref,
                    ),
                    childCount: listings.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ── Profile Header Widget ─────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> profile;
  final WidgetRef ref;
  const _ProfileHeader({required this.profile, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isVerified = profile['is_verified'] as bool? ?? false;
    final verificationRequested =
        profile['verification_requested'] as bool? ?? false;
    final photoUrl = profile['profile_photo_url'] as String?;
    final fullName = profile['full_name'] as String? ?? '';
    final wilaya = profile['wilaya'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.primaryColor.withAlpha(50),
                  backgroundImage: photoUrl != null
                      ? CachedNetworkImageProvider(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              fullName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            wilaya,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (!isVerified)
              verificationRequested
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.hourglass_top,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.verificationRequested,
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await ref
                                .read(authRepositoryProvider)
                                .requestVerificationBadge();
                            ref.invalidate(currentUserProfileProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.verificationRequestSent),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.shield_outlined),
                        label: Text(l10n.requestVerification),
                      ),
                    ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderSkeleton extends StatelessWidget {
  const _ProfileHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: const SizedBox(height: 120),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final List<Listing> listings;
  final AppLocalizations l10n;
  const _StatsRow({required this.listings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final total = listings.length;
    final active = listings.where((l) => l.status == 'available').length;
    final totalViews = listings.fold<int>(0, (sum, l) => sum + l.viewCount);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.totalListings,
              value: total.toString(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: l10n.activeListings,
              value: active.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Listing Management Tile ───────────────────────────────────────────────────

class _ListingManagementTile extends StatelessWidget {
  final Listing listing;
  final AppLocalizations l10n;
  final WidgetRef ref;

  const _ListingManagementTile({
    required this.listing,
    required this.l10n,
    required this.ref,
  });

  bool get _expiresSoon {
    final diff = listing.expiresAt.difference(DateTime.now());
    return diff.inDays <= 7 && diff.isNegative == false;
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirmDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(farmerRepositoryProvider).deleteListing(listing.id);
      ref.invalidate(_myListingsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSold = listing.status == 'sold';
    final photoUrl = listing.photoUrls.isNotEmpty
        ? listing.photoUrls.first
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: photoUrl != null
                    ? CachedNetworkImage(imageUrl: photoUrl, fit: BoxFit.cover)
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StatusBadge(isSold: isSold, l10n: l10n),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          listing.category,
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  if (listing.price != null)
                    Text(
                      '${listing.price!.toStringAsFixed(0)} DZD',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_expiresSoon)
                    Text(
                      l10n.expiresoon,
                      style: const TextStyle(color: Colors.amber, fontSize: 11),
                    ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: l10n.editListing,
                  onPressed: () =>
                      context.push('/farmer/listing/${listing.id}/edit'),
                ),
                IconButton(
                  icon: Icon(
                    isSold ? Icons.check_circle_outline : Icons.circle_outlined,
                    size: 20,
                    color: isSold ? Colors.green : Colors.grey,
                  ),
                  tooltip: isSold ? l10n.markAsAvailable : l10n.markAsSold,
                  onPressed: () async {
                    final newStatus = isSold ? 'available' : 'sold';
                    await ref
                        .read(farmerRepositoryProvider)
                        .toggleListingStatus(listing.id, newStatus);
                    ref.invalidate(_myListingsProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outlined,
                    size: 20,
                    color: Colors.red,
                  ),
                  tooltip: l10n.deleteListing,
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isSold;
  final AppLocalizations l10n;
  const _StatusBadge({required this.isSold, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isSold ? Colors.red.withAlpha(30) : Colors.green.withAlpha(30),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isSold ? Colors.red : Colors.green,
          width: 0.5,
        ),
      ),
      child: Text(
        isSold ? l10n.sold : l10n.available,
        style: TextStyle(
          fontSize: 11,
          color: isSold ? Colors.red : Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
