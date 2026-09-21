import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import '../widgets/product_card.dart';

class SellerProfileScreen extends StatelessWidget {
  final UserModel seller;

  const SellerProfileScreen({super.key, required this.seller});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final sellerProducts = state.products.where((p) => p.seller.id == seller.id && (p.status == 'active' || p.status == 'sold')).toList();
        final reviews = state.getReviewsForSeller(seller.id);
        final averageRating = state.getAverageRating(seller.id);

        return Scaffold(
          appBar: AppBar(
            title: Text('หน้าร้าน: ${seller.effectiveName}'),
          ),
          body: MaxWidthContainer(
            maxWidth: 1000,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seller Card Header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundImage: seller.avatarUrl.isNotEmpty
                                    ? NetworkImage(seller.avatarUrl)
                                    : null,
                                child: seller.avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 36)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          seller.effectiveName,
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                        if (seller.isVerified) ...[
                                          const SizedBox(width: 6),
                                          const Tooltip(
                                            message: 'ผ่านการยืนยันตัวตนด้วยบัตรนักศึกษาแล้ว',
                                            child: Icon(Icons.verified, color: AppTheme.primaryLight, size: 20),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${reviews.length} รีวิวจากผู้ซื้อ)',
                                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    if (seller.bio.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        seller.bio,
                                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem('สินค้าที่ลงขาย', '${sellerProducts.length} ชิ้น'),
                              _buildStatItem('เบอร์ติดต่อ', seller.phoneNumber.isNotEmpty ? seller.phoneNumber : 'ไม่ระบุ'),
                              _buildStatItem('คะแนนเฉลี่ย', '${averageRating.toStringAsFixed(1)} / 5.0'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reviews Header & Add Review Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'คะแนนและรีวิว (${reviews.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (seller.id != state.currentUser.id)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
                          icon: const Icon(Icons.rate_review_outlined, size: 16),
                          label: const Text('เขียนรีวิว'),
                          onPressed: () => _showAddReviewDialog(context, state),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (reviews.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'ยังไม่มีรีวิวสำหรับผู้ขายท่านนี้ เป็นคนแรกที่รีวิวเลย!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (context, sepIdx) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundImage: r.reviewer.avatarUrl.isNotEmpty
                                              ? NetworkImage(r.reviewer.avatarUrl)
                                              : null,
                                          child: r.reviewer.avatarUrl.isEmpty
                                              ? const Icon(Icons.person, size: 14)
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(r.reviewer.effectiveName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Row(
                                      children: List.generate(5, (starIdx) {
                                        return Icon(
                                          starIdx < r.rating ? Icons.star : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                                if (r.comment.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(r.comment, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                                ],
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm').format(r.createdAt),
                                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 28),

                  // Products by this seller
                  Text(
                    'สินค้าของผู้ขายรายนี้ (${sellerProducts.length})',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  if (sellerProducts.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Text('ไม่มีสินค้าที่กำลังลงขาย', style: TextStyle(color: Colors.grey[600])),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.isDesktop(context) ? 4 : (Responsive.isTablet(context) ? 3 : 2),
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: sellerProducts.length,
                      itemBuilder: (context, index) {
                        return ProductCard(product: sellerProducts[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _showAddReviewDialog(BuildContext context, AppState state) {
    int currentRating = 5;
    final commentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('ให้คะแนน ${seller.effectiveName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setDialogState(() => currentRating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'เขียนรีวิวความประทับใจ การส่งของ สภาพสินค้า...',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ยกเลิก'),
                ),
                ElevatedButton(
                  onPressed: () {
                    state.addReview(
                      sellerId: seller.id,
                      rating: currentRating,
                      comment: commentCtrl.text.trim(),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('ขอบคุณสำหรับรีวิวของคุณ!'), backgroundColor: AppTheme.success),
                    );
                  },
                  child: const Text('ส่งรีวิว'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
