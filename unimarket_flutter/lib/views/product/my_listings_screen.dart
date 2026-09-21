import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'th_TH');

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('สินค้าของฉัน (My Listings)'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.primary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(text: 'ทั้งหมด'),
              Tab(text: 'กำลังขาย'),
              Tab(text: 'รอตรวจสอบ'),
              Tab(text: 'ขายแล้ว'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductFormScreen()),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('ลงขายสินค้า'),
        ),
        body: Consumer<AppState>(
          builder: (context, state, _) {
            final all = state.myListings;
            final active = all.where((p) => p.status == 'active').toList();
            final pending = all.where((p) => p.status == 'pending').toList();
            final sold = all.where((p) => p.status == 'sold').toList();

            return TabBarView(
              children: [
                _buildProductList(context, state, all, currencyFormatter),
                _buildProductList(context, state, active, currencyFormatter),
                _buildProductList(context, state, pending, currencyFormatter),
                _buildProductList(context, state, sold, currencyFormatter),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductList(
    BuildContext context,
    AppState state,
    List<dynamic> items,
    NumberFormat formatter,
  ) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
            SizedBox(height: 12),
            Text('ยังไม่มีรายการสินค้าในหมวดหมู่นี้', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    return MaxWidthContainer(
      maxWidth: 900,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (context, sepIdx) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = items[index];
          return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: product.id)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: product.status == 'active'
                                      ? AppTheme.success.withAlpha(40)
                                      : (product.status == 'sold' ? AppTheme.danger.withAlpha(40) : AppTheme.warning.withAlpha(40)),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  product.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: product.status == 'active'
                                        ? AppTheme.success
                                        : (product.status == 'sold' ? AppTheme.danger : AppTheme.warning),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                product.conditionLabel,
                                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '฿${formatter.format(product.price)}',
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProductFormScreen(productToEdit: product)),
                          );
                        } else if (action == 'sold') {
                          state.markAsSold(product.id);
                        } else if (action == 'delete') {
                          state.deleteProduct(product.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('✏️ แก้ไขข้อมูล')),
                        if (product.status != 'sold')
                          const PopupMenuItem(value: 'sold', child: Text('✅ ปรับเป็นขายแล้ว')),
                        const PopupMenuItem(value: 'delete', child: Text('🗑️ ลบสินค้า')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
