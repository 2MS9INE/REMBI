import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/listing_detail_provider.dart';
import '../../../seller/presentation/providers/seller_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/report_modal.dart';

class ListingDetailScreen extends ConsumerWidget {
  final String listingId;

  const ListingDetailScreen({super.key, required this.listingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final asyncListing = ref.watch(listingDetailProvider(listingId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.listingDetailsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => ReportModal(listingId: listingId),
              );
            },
          ),
        ],
      ),
      body: asyncListing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.error),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(listingDetailProvider(listingId));
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (listing) {
          return Stack(
            children: [
              Positioned.fill(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _PhotoGallery(photoUrls: listing.photoUrls),
                    ),
                    SliverToBoxAdapter(
                      child: _InfoSection(listing: listing, l10n: l10n),
                    ),
                    if (listing.dynamicFields.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _DynamicFieldsSection(
                          dynamicFields: listing.dynamicFields,
                          l10n: l10n,
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _DescriptionSection(
                        description: listing.description,
                        l10n: l10n,
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 120,
                      ), // padding for sticky contact
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _StickyContactSection(
                  farmerId: listing.farmerId,
                  l10n: l10n,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoGallery extends ConsumerStatefulWidget {
  final List<String> photoUrls;

  const _PhotoGallery({required this.photoUrls});

  @override
  ConsumerState<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends ConsumerState<_PhotoGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.photoUrls.isEmpty) {
      return Container(
        height: 250,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.agriculture, size: 64, color: Colors.grey),
        ),
      );
    }

    final count = widget.photoUrls.length > 5 ? 5 : widget.photoUrls.length;

    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            itemCount: count,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.photoUrls[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            },
          ),
        ),
        if (count > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(count, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withAlpha(100),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final dynamic listing;
  final AppLocalizations l10n;

  const _InfoSection({required this.listing, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSold = listing.status == 'sold';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isSold)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.center,
            child: Text(
              l10n.sold,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.price != null
                          ? '${listing.price!.toStringAsFixed(2)} DZD'
                          : l10n.priceUponContact,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  if (listing.isNegotiable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(50),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Text(
                        l10n.negotiable,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(
                      listing.category,
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    side: BorderSide.none,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    listing.wilaya,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DynamicFieldsSection extends StatelessWidget {
  final Map<String, dynamic> dynamicFields;
  final AppLocalizations l10n;

  const _DynamicFieldsSection({
    required this.dynamicFields,
    required this.l10n,
  });

  static const Map<String, Map<String, String>> _fieldLabels = {
    'species': {'ar': 'النوع', 'fr': 'Espèce', 'en': 'Species'},
    'age_months': {
      'ar': 'العمر (أشهر)',
      'fr': 'Âge (mois)',
      'en': 'Age (months)',
    },
    'weight_kg': {'ar': 'الوزن (كغ)', 'fr': 'Poids (kg)', 'en': 'Weight (kg)'},
    'sex': {'ar': 'الجنس', 'fr': 'Sexe', 'en': 'Sex'},
    'health_status': {
      'ar': 'الحالة الصحية',
      'fr': 'État de santé',
      'en': 'Health Status',
    },
    'breed': {'ar': 'السلالة', 'fr': 'Race', 'en': 'Breed'},
    'vaccinated': {'ar': 'ملقح', 'fr': 'Vacciné', 'en': 'Vaccinated'},
    'color': {'ar': 'اللون', 'fr': 'Couleur', 'en': 'Color'},
    'quantity': {'ar': 'الكمية', 'fr': 'Quantité', 'en': 'Quantity'},
    'notes': {'ar': 'ملاحظات', 'fr': 'Notes', 'en': 'Notes'},
    'crop_type': {
      'ar': 'نوع المحصول',
      'fr': 'Type de culture',
      'en': 'Crop Type',
    },
    'quantity_kg': {
      'ar': 'الكمية (كغ)',
      'fr': 'Quantité (kg)',
      'en': 'Quantity (kg)',
    },
    'harvest_date': {
      'ar': 'تاريخ الحصاد',
      'fr': 'Date de récolte',
      'en': 'Harvest Date',
    },
    'organic': {'ar': 'عضوي', 'fr': 'Biologique', 'en': 'Organic'},
    'packaging': {'ar': 'التعبئة', 'fr': 'Emballage', 'en': 'Packaging'},
    'service_type': {
      'ar': 'نوع الخدمة',
      'fr': 'Type de service',
      'en': 'Service Type',
    },
    'duration': {'ar': 'المدة', 'fr': 'Durée', 'en': 'Duration'},
    'availability': {
      'ar': 'التوفر',
      'fr': 'Disponibilité',
      'en': 'Availability',
    },
    'material': {'ar': 'المادة', 'fr': 'Matériau', 'en': 'Material'},
    'handmade': {'ar': 'صنع يدوي', 'fr': 'Fait main', 'en': 'Handmade'},
    'dimensions': {'ar': 'الأبعاد', 'fr': 'Dimensions', 'en': 'Dimensions'},
  };

  String _getLabel(String key, String langCode) {
    return _fieldLabels[key]?[langCode] ?? _fieldLabels[key]?['en'] ?? key;
  }

  String _getValue(dynamic value, String langCode) {
    if (value == true)
      return langCode == 'ar'
          ? 'نعم'
          : langCode == 'fr'
          ? 'Oui'
          : 'Yes';
    if (value == false)
      return langCode == 'ar'
          ? 'لا'
          : langCode == 'fr'
          ? 'Non'
          : 'No';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            l10n.listingDetailsTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...dynamicFields.entries
              .where((e) => e.value != null && e.value.toString().isNotEmpty)
              .map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _getLabel(e.key, langCode),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          _getValue(e.value, langCode),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }
}

class _DescriptionSection extends ConsumerStatefulWidget {
  final String description;
  final AppLocalizations l10n;

  const _DescriptionSection({required this.description, required this.l10n});

  @override
  ConsumerState<_DescriptionSection> createState() =>
      _DescriptionSectionState();
}

class _DescriptionSectionState extends ConsumerState<_DescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),
          Text(
            widget.l10n.descriptionTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.description,
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          if (!_isExpanded && widget.description.length > 100)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = true),
                child: Text(widget.l10n.readMore),
              ),
            ),
        ],
      ),
    );
  }
}

class _StickyContactSection extends ConsumerWidget {
  final String farmerId;
  final AppLocalizations l10n;

  const _StickyContactSection({required this.farmerId, required this.l10n});

  void _launchPhone(String phone) async {
    final Uri url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _launchWhatsApp(String phone) async {
    final message = Uri.encodeComponent("مرحبا، رأيت إعلانك على تطبيق رمبي");
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('https://wa.me/$cleanPhone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final asyncSeller = ref.watch(sellerProfileProvider(farmerId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: asyncSeller.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Text(l10n.error),
        data: (seller) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: seller.profilePhotoUrl != null
                        ? CachedNetworkImageProvider(seller.profilePhotoUrl!)
                        : null,
                    backgroundColor: theme.primaryColor.withAlpha(50),
                    child: seller.profilePhotoUrl == null
                        ? Text(seller.fullName[0].toUpperCase())
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              seller.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (seller.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              seller.averageRating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (seller.phone != null) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.phone,
                                size: 18,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                seller.phone!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/seller/$farmerId');
                    },
                    icon: const Icon(Icons.person),
                    label: Text(l10n.viewProfile),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.primaryColor),
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: seller.phone != null
                          ? () => _launchPhone(seller.phone!)
                          : null,
                      icon: const Icon(Icons.phone),
                      label: Text(l10n.call),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: seller.whatsapp != null
                          ? () => _launchWhatsApp(seller.whatsapp!)
                          : null,
                      icon: const Icon(Icons.chat),
                      label: Text(l10n.whatsapp),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
