import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/section_header.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.add_business), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MarketHero(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Categories',
                  subtitle: 'Browse products and services',
                ),
                const SizedBox(height: 12),
                _CategoriesGrid(),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Featured Listings',
                  subtitle: 'Popular products from women in your area',
                  actionLabel: 'See all',
                  onAction: null,
                ),
                const SizedBox(height: 12),
                _FeaturedListings(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MarketHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.marketplaceColor.withValues(alpha: 0.12),
            AppColors.earnColor.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.marketplaceColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sell your products & services',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Connect with buyers in your community and beyond. List your products, set prices, and grow your business.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, size: 18),
            label: const Text('List a Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.marketplaceColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  static const _categories = [
    ('Agriculture', Icons.grass, AppColors.healthColor),
    ('Crafts', Icons.palette, AppColors.mentorshipColor),
    ('Food & Drink', Icons.restaurant, AppColors.marketplaceColor),
    ('Fashion', Icons.checkroom, AppColors.thriveColor),
    ('Beauty', Icons.spa, AppColors.wellbeingColor),
    ('Services', Icons.handyman, AppColors.financeColor),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.2,
      children: _categories.map((c) {
        return InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: c.$3.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.$3.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(c.$2, color: c.$3, size: 28),
                const SizedBox(height: 6),
                Text(
                  c.$1,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FeaturedListings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final listings = [
      _Listing('Fresh Organic Vegetables', 'Sarah M. · Mukono',
          'UGX 15,000', AppColors.healthColor),
      _Listing('Handwoven Baskets', 'Grace K. · Jinja',
          'UGX 35,000', AppColors.mentorshipColor),
      _Listing('Shea Butter Soap', 'Peace N. · Gulu',
          'UGX 8,000', AppColors.wellbeingColor),
    ];

    return Column(
      children: listings
          .map(
            (l) => Card(
              child: ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: l.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_bag, color: l.color),
                ),
                title: Text(l.title,
                    style: Theme.of(context).textTheme.titleMedium),
                subtitle: Text(l.seller),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.earnColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    l.price,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.earnColor,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _Listing {
  const _Listing(this.title, this.seller, this.price, this.color);
  final String title;
  final String seller;
  final String price;
  final Color color;
}
