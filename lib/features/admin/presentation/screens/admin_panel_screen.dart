import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/admin_repository.dart';
import '../providers/admin_provider.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    // Load listings on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminListingsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Admin role guard
    final profileAsync = ref.watch(currentUserProfileProvider);
    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
        return const SizedBox.shrink();
      },
      data: (profile) {
        if (profile == null || profile['role'] != 'admin') {
          WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/'));
          return const SizedBox.shrink();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.adminPanel),
            bottom: TabBar(
              controller: _tabs,
              isScrollable: false,
              tabs: [
                Tab(icon: const Icon(Icons.bar_chart), text: l10n.adminStats),
                Tab(icon: const Icon(Icons.flag), text: l10n.adminReports),
                Tab(
                  icon: const Icon(Icons.verified_user),
                  text: l10n.adminVerifications,
                ),
                Tab(icon: const Icon(Icons.list_alt), text: l10n.adminListings),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabs,
            children: [
              _StatsTab(l10n: l10n),
              _ReportsTab(l10n: l10n),
              _VerificationsTab(l10n: l10n),
              _ListingsTab(l10n: l10n),
            ],
          ),
        );
      },
    );
  }
}

// ── TAB 1: Stats Dashboard ───────────────────────────────────────────────────

class _StatsTab extends ConsumerWidget {
  final AppLocalizations l10n;
  const _StatsTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(platformStatsProvider);
    final verAsync = ref.watch(pendingVerificationsProvider);
    final repAsync = ref.watch(pendingReportsProvider);
    final theme = Theme.of(context);

    return statsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (stats) {
        final pendVerif = verAsync.maybeWhen(
          data: (v) => v.length,
          orElse: () => 0,
        );
        final pendRep = repAsync.maybeWhen(
          data: (r) => r.length,
          orElse: () => 0,
        );
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(platformStatsProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 2×2 metric grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _MetricCard(
                    icon: Icons.agriculture,
                    label: l10n.totalFarmers,
                    value: stats.totalFarmers.toString(),
                    color: theme.primaryColor,
                  ),
                  _MetricCard(
                    icon: Icons.list_alt,
                    label: l10n.totalListings,
                    value: stats.totalListings.toString(),
                    color: Colors.blue,
                  ),
                  _MetricCard(
                    icon: Icons.flag,
                    label: l10n.pendingReports,
                    value: pendRep.toString(),
                    color: pendRep > 0 ? Colors.red : theme.primaryColor,
                  ),
                  _MetricCard(
                    icon: Icons.verified_user,
                    label: l10n.pendingVerifications,
                    value: pendVerif.toString(),
                    color: pendVerif > 0 ? Colors.amber : theme.primaryColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Category bar chart
              Text(
                l10n.listingsByCategory,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...stats.listingsPerCategory.entries.map(
                (e) => _CategoryBar(
                  category: e.key,
                  count: e.value,
                  max: stats.listingsPerCategory.values.fold(
                    1,
                    (a, b) => a > b ? a : b,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Top wilayas
              Text(
                l10n.topWilayas,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...stats.topWilayas.asMap().entries.map((e) {
                final max = stats.topWilayas.first.count;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '#${e.key + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.wilaya),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: e.value.count / max,
                                minHeight: 6,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(
                                  theme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${e.value.count}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // 7-day bar chart
              Text(
                l10n.dailyNewListings,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _DailyBarChart(stats: stats, theme: theme),
            ],
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 6),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

final _categoryColors = {
  'LIVESTOCK': Colors.green,
  'CROPS': Colors.amber,
  'ARTISAN PRODUCTS': Colors.teal,
  'AGRICULTURAL SERVICES': Colors.blue,
};

class _CategoryBar extends StatelessWidget {
  final String category;
  final int count;
  final int max;

  const _CategoryBar({
    required this.category,
    required this.count,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    final color = _categoryColors[category.toUpperCase()] ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              category,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: count / max,
                minHeight: 14,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DailyBarChart extends StatelessWidget {
  final PlatformStats stats;
  final ThemeData theme;
  const _DailyBarChart({required this.stats, required this.theme});

  @override
  Widget build(BuildContext context) {
    if (stats.dailyNewListings.isEmpty) {
      return const Text('No data yet');
    }
    final max = stats.dailyNewListings
        .map((d) => d.count)
        .fold(1, (a, b) => a > b ? a : b);
    const maxHeight = 100.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: stats.dailyNewListings.map((d) {
        final barH = (d.count / max) * maxHeight;
        final label = d.date.substring(5); // MM-dd
        return Expanded(
          child: Column(
            children: [
              Text(
                '${d.count}',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                height: barH.clamp(4.0, maxHeight),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 9),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── TAB 2: Reports ───────────────────────────────────────────────────────────

class _ReportsTab extends ConsumerWidget {
  final AppLocalizations l10n;
  const _ReportsTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(pendingReportsProvider);
    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                Text(l10n.noReports),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingReportsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) => _ReportCard(
              report: reports[i],
              l10n: l10n,
              onDismiss: () async {
                await ref
                    .read(adminRepositoryProvider)
                    .dismissReport(reports[i].id);
                ref.invalidate(pendingReportsProvider);
              },
              onRemoveListing: () async {
                final confirmed = await _confirm(
                  ctx,
                  l10n.deleteConfirmTitle,
                  l10n.deleteConfirmMessage,
                );
                if (!confirmed) return;
                await ref
                    .read(adminRepositoryProvider)
                    .removeListingFromReport(
                      reports[i].id,
                      reports[i].listingId,
                    );
                ref.invalidate(pendingReportsProvider);
              },
              onWarnFarmer: () async {
                final msg = await _inputDialog(ctx, l10n.warnFarmerTitle);
                if (msg == null || msg.isEmpty) return;
                try {
                  await ref
                      .read(adminRepositoryProvider)
                      .warnFarmer(reports[i].listingId, msg);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(
                      ctx,
                    ).showSnackBar(SnackBar(content: Text(l10n.warnSent)));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text('فشل الإرسال: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool> _confirm(BuildContext ctx, String title, String body) async {
    return await showDialog<bool>(
          context: ctx,
          builder: (c) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: Text(MaterialLocalizations.of(c).cancelButtonLabel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<String?> _inputDialog(BuildContext ctx, String title) async {
    String msg = '';
    return showDialog<String>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: TextField(
          autofocus: true,
          maxLines: 3,
          onChanged: (v) => msg = v,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(MaterialLocalizations.of(c).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, msg),
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }
}

final _reasonColors = {
  'scam': Colors.red,
  'fake': Colors.orange,
  'duplicate': Colors.yellow.shade700,
  'inappropriate': Colors.grey,
};

class _ReportCard extends StatelessWidget {
  final Report report;
  final AppLocalizations l10n;
  final VoidCallback onDismiss;
  final VoidCallback onRemoveListing;
  final VoidCallback onWarnFarmer;

  const _ReportCard({
    required this.report,
    required this.l10n,
    required this.onDismiss,
    required this.onRemoveListing,
    required this.onWarnFarmer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reasonColor =
        _reasonColors[report.reason.toLowerCase()] ?? Colors.grey;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.listingTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(report.farmerName, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: reasonColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: reasonColor.withAlpha(120)),
                  ),
                  child: Text(
                    report.reason,
                    style: TextStyle(
                      fontSize: 11,
                      color: reasonColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(report.createdAt),
              style: theme.textTheme.labelSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDismiss,
                    child: Text(l10n.dismiss),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: onRemoveListing,
                    child: Text(l10n.removeListing),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: FilledButton(
                    onPressed: onWarnFarmer,
                    child: Text(l10n.warnFarmer),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';
}

// ── TAB 3: Verifications ─────────────────────────────────────────────────────

class _VerificationsTab extends ConsumerWidget {
  final AppLocalizations l10n;
  const _VerificationsTab({required this.l10n});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verifAsync = ref.watch(pendingVerificationsProvider);
    return verifAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 64,
                  color: Colors.green,
                ),
                const SizedBox(height: 12),
                Text(l10n.noVerificationRequests),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingVerificationsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final farmer = list[i];
              return _VerificationCard(
                farmer: farmer,
                l10n: l10n,
                onApprove: () async {
                  try {
                    await ref
                        .read(adminRepositoryProvider)
                        .approveVerification(farmer['id'] as String);
                    ref.invalidate(pendingVerificationsProvider);
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(l10n.verificationApproved)),
                      );
                    }
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('خطأ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                onReject: () async {
                  try {
                    await ref
                        .read(adminRepositoryProvider)
                        .rejectVerification(farmer['id'] as String);
                    ref.invalidate(pendingVerificationsProvider);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('خطأ: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final Map<String, dynamic> farmer;
  final AppLocalizations l10n;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _VerificationCard({
    required this.farmer,
    required this.l10n,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = farmer['profile_photo_url'] as String?;
    final createdAt = DateTime.tryParse(farmer['created_at'] as String? ?? '');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: photoUrl != null
                      ? NetworkImage(photoUrl)
                      : null,
                  child: photoUrl == null
                      ? const Icon(Icons.person, size: 28)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmer['full_name'] as String? ?? '—',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        farmer['wilaya'] as String? ?? '—',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        farmer['phone'] as String? ?? '—',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (createdAt != null)
                        Text(
                          '${l10n.memberSince} ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                          style: theme.textTheme.labelSmall,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: onApprove,
                    child: Text(l10n.approve),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: onReject,
                    child: Text(l10n.reject),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── TAB 4: Listings Manager ──────────────────────────────────────────────────

class _ListingsTab extends ConsumerStatefulWidget {
  final AppLocalizations l10n;
  const _ListingsTab({required this.l10n});

  @override
  ConsumerState<_ListingsTab> createState() => _ListingsTabState();
}

class _ListingsTabState extends ConsumerState<_ListingsTab> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(adminListingsProvider);
    final notifier = ref.read(adminListingsProvider.notifier);
    final l10n = widget.l10n;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: l10n.search,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (q) => notifier.setQuery(q),
          ),
        ),
        Expanded(
          child: listings.isEmpty
              ? Center(child: Text(l10n.noResults))
              : NotificationListener<ScrollNotification>(
                  onNotification: (n) {
                    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
                      notifier.load();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: listings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final listing = listings[i];
                      return _AdminListingRow(
                        listing: listing,
                        l10n: l10n,
                        onPin: () async {
                          try {
                            await ref
                                .read(adminRepositoryProvider)
                                .pinListing(listing.id);
                            notifier.load(reset: true);
                          } catch (e) {
                            if (e.toString().contains('pin_limit_reached') &&
                                ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(l10n.pinLimitError)),
                              );
                            }
                          }
                        },
                        onUnpin: () async {
                          await ref
                              .read(adminRepositoryProvider)
                              .unpinListing(listing.id);
                          notifier.load(reset: true);
                        },
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

class _AdminListingRow extends StatelessWidget {
  final AdminListing listing;
  final AppLocalizations l10n;
  final VoidCallback onPin;
  final VoidCallback onUnpin;

  const _AdminListingRow({
    required this.listing,
    required this.l10n,
    required this.onPin,
    required this.onUnpin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = listing.photoUrls.isNotEmpty
        ? listing.photoUrls.first
        : null;
    final isFeatured = listing.isFeatured;

    return Card(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: photoUrl != null
              ? Image.network(
                  photoUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: 48,
                  height: 48,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported),
                ),
        ),
        title: Text(
          listing.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${listing.category} • ${listing.wilaya}',
          style: theme.textTheme.labelSmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusBadge(status: listing.status, l10n: l10n),
            IconButton(
              icon: Icon(
                isFeatured ? Icons.star : Icons.star_outline,
                color: isFeatured ? Colors.amber : null,
              ),
              onPressed: isFeatured ? onUnpin : onPin,
              tooltip: isFeatured ? l10n.unpin : l10n.pin,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'available':
        color = Colors.green;
        label = l10n.available;
        break;
      case 'sold':
        color = Colors.red;
        label = l10n.sold;
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
