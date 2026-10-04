import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/responsive.dart';
import '../widgets/product_card.dart';

class WishlistScreen extends StatelessWidget {
  final bool showAppBar;
  const WishlistScreen({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('รายการโปรด (Wishlist)'),
            )
          : null,
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final items = state.wishlistProducts;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('ยังไม่มีสินค้าในรายการโปรด', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('กดรูปหัวใจที่สินค้าที่คุณสนใจเพื่อบันทึกไว้ดูภายหลัง', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          final isDesktop = Responsive.isDesktop(context);
          final isTablet = Responsive.isTablet(context);
          final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

          return MaxWidthContainer(
            maxWidth: 1200,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ProductCard(product: items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
