import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import '../chat/chat_room_screen.dart';
import '../profile/seller_profile_screen.dart';
import '../widgets/report_dialog.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,##0', 'th_TH');

    return Consumer<AppState>(
      builder: (context, state, _) {
        final productList = state.products.where((p) => p.id == productId).toList();
        if (productList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('ไม่พบสินค้า')),
            body: const Center(child: Text('สินค้านี้อาจถูกลบหรือไม่มีอยู่ในระบบ')),
          );
        }

        final product = productList.first;
        final isOwner = product.seller.id == state.currentUser.id;
        final isAdmin = state.currentUser.isAdmin;
        final averageRating = state.getAverageRating(product.seller.id);

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavorite ? AppTheme.danger : null,
                ),
                onPressed: () => state.toggleFavorite(product.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('คัดลอกลิงก์สินค้าเรียบร้อยแล้ว')),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'report') {
                    showDialog(
                      context: context,
                      builder: (_) => ReportDialog(
                        productId: product.id,
                        productName: product.name,
                        reportedUserId: product.seller.id,
                        reportedUserName: product.seller.effectiveName,
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.report_problem_outlined, color: AppTheme.danger, size: 20),
                        SizedBox(width: 8),
                        Text('รายงานสินค้านี้'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: MaxWidthContainer(
            maxWidth: 900,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 360,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) => const Center(
                          child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Status and Condition Tags
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: product.condition == 'new' ? AppTheme.success : Colors.blueGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.conditionLabel,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: product.status == 'active'
                              ? AppTheme.success.withAlpha(30)
                              : (product.status == 'sold' ? AppTheme.danger.withAlpha(30) : AppTheme.warning.withAlpha(30)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.statusLabel,
                          style: TextStyle(
                            color: product.status == 'active'
                                ? AppTheme.success
                                : (product.status == 'sold' ? AppTheme.danger : AppTheme.warning),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (product.category != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          avatar: Text(product.category!.icon),
                          label: Text(product.category!.name, style: const TextStyle(fontSize: 12)),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '฿${currencyFormatter.format(product.price)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 8),

                  // Description Title
                  const Text(
                    'รายละเอียดสินค้า',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Seller Profile Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: product.seller.avatarUrl.isNotEmpty
                                ? NetworkImage(product.seller.avatarUrl)
                                : null,
                            child: product.seller.avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 28)
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      product.seller.effectiveName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (product.seller.isVerified) ...[
                                      const SizedBox(width: 4),
                                      const Icon(Icons.verified, size: 16, color: AppTheme.primaryLight),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 16, color: Colors.amber),
                                    const SizedBox(width: 4),
                                    Text(
                                      averageRating.toStringAsFixed(1),
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${state.getReviewsForSeller(product.seller.id).length} รีวิว)',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SellerProfileScreen(seller: product.seller),
                                ),
                              );
                            },
                            child: const Text('ดูร้านค้า'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Admin Action Box (if admin)
                  if (isAdmin) ...[
                    Card(
                      color: const Color(0xFFFEF3C7),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🛠️ แผงควบคุมผู้ดูแลระบบ (Admin Controls)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if (product.status != 'active')
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                    icon: const Icon(Icons.check_circle_outline, size: 18),
                                    label: const Text('อนุมัติสินค้า'),
                                    onPressed: () {
                                      state.approveProduct(product.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('อนุมัติสินค้าเรียบร้อย')),
                                      );
                                    },
                                  ),
                                if (product.status != 'rejected')
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppTheme.danger),
                                    icon: const Icon(Icons.cancel_outlined, size: 18),
                                    label: const Text('ปฏิเสธ'),
                                    onPressed: () => state.rejectProduct(product.id),
                                  ),
                                if (product.status != 'suspended')
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                                    icon: const Icon(Icons.pause_circle_outline, size: 18),
                                    label: const Text('ระงับสินค้า'),
                                    onPressed: () => state.suspendProduct(product.id),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Owner Actions (Edit, Mark as Sold, Delete)
                  if (isOwner) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'จัดการสินค้าของคุณ',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (product.status != 'sold')
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
                                      icon: const Icon(Icons.done_all, size: 18),
                                      label: const Text('ทำเครื่องหมายว่าขายแล้ว'),
                                      onPressed: () {
                                        state.markAsSold(product.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('ปรับสถานะเป็นขายแล้ว')),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('แก้ไข'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProductFormScreen(productToEdit: product),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('ยืนยันการลบสินค้า'),
                                        content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบสินค้านี้ออกจากระบบ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: const Text('ยกเลิก'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                            onPressed: () {
                                              state.deleteProduct(product.id);
                                              Navigator.pop(ctx);
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('ลบสินค้าเรียบร้อยแล้ว')),
                                              );
                                            },
                                            child: const Text('ลบสินค้า'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          bottomSheet: !isOwner
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: MaxWidthContainer(
                      maxWidth: 900,
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text(
                                'ทักแชทคุยกับผู้ขาย',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                final room = state.getOrCreateChatRoom(product);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatRoomScreen(roomId: room.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
