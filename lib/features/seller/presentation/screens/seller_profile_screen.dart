import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/seller_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../listing/presentation/widgets/listing_card.dart';
import '../widgets/review_card.dart';
import '../widgets/add_review_modal.dart';

class SellerProfileScreen extends ConsumerWidget {
  final String sellerId;

  const SellerProfileScreen({super.key, required this.sellerId});

  void _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final asyncProfile = ref.watch(sellerProfileProvider(sellerId));
    final asyncListings = ref.watch(sellerListingsProvider(sellerId));
    final asyncReviews = ref.watch(sellerReviewsProvider(sellerId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.viewProfile),
      ),
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text(l10n.error)),
        data: (seller) {
          return CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: theme.primaryColor.withAlpha(50),
                        backgroundImage: seller.profilePhotoUrl != null
                            ? CachedNetworkImageProvider(seller.profilePhotoUrl!)
                            : null,
                        child: seller.profilePhotoUrl == null
                            ? Text(
                                seller.fullName[0].toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            seller.fullName,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          if (seller.isVerified) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${seller.averageRating.toStringAsFixed(1)} (${seller.totalReviews} ${l10n.reviews})',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(seller.wilaya, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (seller.phone != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _launchPhone(seller.phone!),
                                icon: const Icon(Icons.phone),
                                label: Text(l10n.call),
                              ),
                            ),
                          const SizedBox(width: 16),
                          if (seller.whatsapp != null)
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: () => _launchWhatsApp(seller.whatsapp!),
                                icon: const Icon(Icons.chat, color: Colors.white),
                                label: Text(l10n.whatsapp, style: const TextStyle(color: Colors.white)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                    ],
                  ),
                ),
              ),

              // Listings Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    l10n.sellerListings,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              asyncListings.when(
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                error: (e, st) => SliverToBoxAdapter(child: Center(child: Text(l10n.error))),
                data: (listings) {
                  if (listings.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No active listings."),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Matching listing card ratio
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ListingCard(listing: listings[index]);
                        },
                        childCount: listings.length,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              const SliverToBoxAdapter(child: Divider()),

              // Reviews Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.reviews,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (context) => AddReviewModal(sellerId: sellerId),
                          );
                        },
                        icon: const Icon(Icons.rate_review),
                        label: Text(l10n.addReview),
                      )
                    ],
                  ),
                ),
              ),
              asyncReviews.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator())),
                ),
                error: (e, st) => SliverToBoxAdapter(
                  child: Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text(l10n.error))),
                ),
                data: (reviews) {
                  if (reviews.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No reviews yet."),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return ReviewCard(review: reviews[index]);
                        },
                        childCount: reviews.length,
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 64)),
            ],
          );
        },
      ),
    );
  }
}
