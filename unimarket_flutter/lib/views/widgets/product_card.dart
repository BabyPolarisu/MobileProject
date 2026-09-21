import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../product/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'th_TH');
    final appState = Provider.of<AppState>(context, listen: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
                // Condition Tag
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.condition == 'new' ? AppTheme.success : Colors.black.withAlpha(178),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.condition == 'new' ? 'มือหนึ่ง' : 'มือสอง',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Sold Tag if sold
                if (product.status == 'sold')
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withAlpha(128),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.danger,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'ขายแล้ว',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // Favorite Button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<AppState>(
                    builder: (context, state, _) {
                      final currentItem = state.products.firstWhere(
                        (p) => p.id == product.id,
                        orElse: () => product,
                      );
                      return Material(
                        color: Colors.white.withAlpha(230),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => appState.toggleFavorite(product.id),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Icon(
                              currentItem.isFavorite ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: currentItem.isFavorite ? AppTheme.danger : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            // Information
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    '฿${currencyFormatter.format(product.price)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Product Name
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Seller & Category Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: product.seller.avatarUrl.isNotEmpty
                            ? NetworkImage(product.seller.avatarUrl)
                            : null,
                        child: product.seller.avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 12)
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          product.seller.effectiveName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (product.seller.isVerified)
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: AppTheme.primaryLight,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
