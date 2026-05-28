import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/wilayas.dart';
import '../../../../core/constants/categories.dart';
import '../providers/home_provider.dart';
import '../../../listing/presentation/widgets/listing_card.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(listingsProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).updateState(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedWilaya = ref.watch(selectedWilayaProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    final isFiltering =
        selectedCategory != null ||
        selectedWilaya != null ||
        searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            SvgPicture.asset('assets/images/ram_icon.png', height: 36),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  l10n.tagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(listingsProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSearchBar(l10n),
                    const SizedBox(height: 16),
                    _buildCategoryChips(l10n),
                    const SizedBox(height: 16),
                    _buildFilterRow(l10n),
                  ],
                ),
              ),
            ),
            if (!isFiltering)
              SliverToBoxAdapter(child: _buildFeaturedListings(l10n)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: _buildListingsGrid(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        hintText: l10n.searchPlaceholder,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryChips(AppLocalizations l10n) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final catKey = categories.keys.elementAt(index);
          final catName =
              categories[catKey]?[languageCode] ??
              categories[catKey]?['en'] ??
              catKey;
          final isSelected =
              ref.watch(selectedCategoryProvider) ==
              (catKey == 'all' ? null : catKey);

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8.0),
            child: ChoiceChip(
              label: Text(catName),
              selected: isSelected,
              onSelected: (selected) {
                ref
                    .read(selectedCategoryProvider.notifier)
                    .updateState(
                      (catKey == 'all' || !selected) ? null : catKey,
                    );
              },
              selectedColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).primaryColor,
              ),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterRow(AppLocalizations l10n) {
    final selectedWilaya = ref.watch(selectedWilayaProvider);

    return Row(
      children: [
        Expanded(
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedWilaya,
                hint: Text(l10n.allWilayas),
                isExpanded: true,
                icon: const Icon(Icons.location_on, size: 20),
                items: [
                  DropdownMenuItem(value: null, child: Text(l10n.allWilayas)),
                  ...algerianWilayas.map(
                    (w) => DropdownMenuItem(value: w, child: Text(w)),
                  ),
                ],
                onChanged: (value) {
                  ref.read(selectedWilayaProvider.notifier).updateState(value);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () => _showSortBottomSheet(l10n),
        ),
      ],
    );
  }

  void _showSortBottomSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentSort = ref.watch(sortByProvider);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.sortBy,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              _buildSortOption('newest', l10n.newest, currentSort),
              _buildSortOption('price_asc', l10n.priceAsc, currentSort),
              _buildSortOption('price_desc', l10n.priceDesc, currentSort),
              _buildSortOption('most_reviewed', l10n.mostReviewed, currentSort),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String value, String label, String currentSort) {
    return ListTile(
      title: Text(label),
      trailing: currentSort == value
          ? const Icon(Icons.check, color: Colors.green)
          : null,
      onTap: () {
        ref.read(sortByProvider.notifier).updateState(value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildFeaturedListings(AppLocalizations l10n) {
    final featuredAsync = ref.watch(featuredListingsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.featuredListingsTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280, // slightly larger
          child: featuredAsync.when(
            data: (listings) {
              if (listings.isEmpty) return const SizedBox.shrink();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: SizedBox(
                      width: 200,
                      child: ListingCard(listing: listings[index]),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 3,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: SizedBox(width: 200, child: _SkeletonCard()),
              ),
            ),
            error: (err, _) => const Center(child: Icon(Icons.error)),
          ),
        ),
      ],
    );
  }

  Widget _buildListingsGrid(AppLocalizations l10n) {
    final listingsAsync = ref.watch(listingsProvider);

    return listingsAsync.when(
      skipLoadingOnReload: true,
      data: (listings) {
        if (listings.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.agriculture, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noResults,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => ListingCard(listing: listings[index]),
            childCount: listings.length,
          ),
        );
      },
      loading: () => SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => const _SkeletonCard(),
          childCount: 4,
        ),
      ),
      error: (err, _) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.error),
              ElevatedButton(
                onPressed: () => ref.read(listingsProvider.notifier).refresh(),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 4),
                Container(height: 12, width: 80, color: Colors.grey[200]),
                const SizedBox(height: 8),
                Container(height: 14, width: 60, color: Colors.grey[200]),
                const SizedBox(height: 4),
                Container(height: 10, width: 100, color: Colors.grey[200]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
