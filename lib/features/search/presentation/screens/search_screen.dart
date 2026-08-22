import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_names.dart';
import '../../domain/entities/item_search_result.dart';
import '../../domain/repositories/search_repository.dart';
import '../repositories/mock_search_repository.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return MockSearchRepository();
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';
  List<ItemSearchResult> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    final searchRepo = ref.read(searchRepositoryProvider);

    final res = await searchRepo.searchItems(
      homeId: 'home-001',
      query: _searchController.text,
      categoryFilter: _selectedCategory.isNotEmpty ? _selectedCategory : null,
    );

    res.when(
      success: (list) => setState(() => _results = list),
      failure: (_) => setState(() => _results = []),
    );
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Inventory'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: (_) => _performSearch(),
                decoration: InputDecoration(
                  hintText: 'Search items (e.g. Camera, Passport, Cable)...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategory.isEmpty,
                      onSelected: (_) {
                        setState(() => _selectedCategory = '');
                        _performSearch();
                      },
                    ),
                  ),
                  ...AppConstants.itemCategories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCategory = val ? cat : '');
                          _performSearch();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search Results List
            Expanded(
              child: _isSearching
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.search_off_rounded,
                                size: 56,
                                color: AppColors.textDisabled,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No matching items found',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final res = _results[index];
                            return _SearchResultCard(result: res);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});

  final ItemSearchResult result;

  @override
  Widget build(BuildContext context) {
    final item = result.item;
    final storage = result.storageUnit;
    final room = result.room;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('${RouteNames.itemDetail}/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLighter,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Category: ${item.category ?? "General"}  •  Qty: ${item.quantity}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Spatial Location Breadcrumb
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2EFE3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${room.name}  ›  ${storage.name} (${storage.qrId})',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
