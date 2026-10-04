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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        final isDesktop = Responsive.isDesktop(context) || MediaQuery.of(context).size.width >= 768;

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            actions: [
              IconButton(
                icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: product.isFavorite ? AppTheme.danger : null,
                ),
                tooltip: product.isFavorite ? 'นำออกจากรายการโปรด' : 'เพิ่มในรายการโปรด',
                onPressed: () => state.toggleFavorite(product.id),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'แชร์สินค้านี้',
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
            maxWidth: 1080,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SingleChildScrollView(
              child: isDesktop
                  ? _buildDesktopLayout(context, state, product, isOwner, isAdmin, averageRating, currencyFormatter, isDark)
                  : _buildMobileLayout(context, state, product, isOwner, isAdmin, averageRating, currencyFormatter, isDark),
            ),
          ),
          // Clean, fixed-height bottom navigation bar only for mobile non-owner
          bottomNavigationBar: (!isDesktop && !isOwner)
              ? Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkSurface : Colors.white,
                    border: Border(
                      top: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 50 : 15),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.darkBackground : const Color(0xFFF1F5F9),
                          padding: const EdgeInsets.all(12),
                        ),
                        icon: Icon(
                          product.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: product.isFavorite ? AppTheme.danger : null,
                        ),
                        onPressed: () => state.toggleFavorite(product.id),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text(
                            'ทักแชทคุยกับผู้ขาย',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => _openChat(context, state, product),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }

  void _openChat(BuildContext context, AppState state, dynamic product) {
    final room = state.getOrCreateChatRoom(product);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(roomId: room.id),
      ),
    );
  }

  // Desktop 2-Column Layout (Matching backend product_detail.html)
  Widget _buildDesktopLayout(
    BuildContext context,
    AppState state,
    dynamic product,
    bool isOwner,
    bool isAdmin,
    double averageRating,
    NumberFormat currencyFormatter,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Large Image & Badges
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(context, product, height: 420),
              const SizedBox(height: 16),
              if (isAdmin) _buildAdminBox(context, state, product, isDark),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Right Column: Details, Price, Specs, Seller, Action Buttons
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tags Row
              _buildStatusAndConditionTags(product),
              const SizedBox(height: 12),

              // Title
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 12),

              // Price
              Text(
                '฿${currencyFormatter.format(product.price)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Specification Box
              _buildSpecBox(context, product, isDark),
              const SizedBox(height: 16),

              // Description
              const Text(
                'รายละเอียดสินค้า',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.description.isNotEmpty ? product.description : 'ไม่มีรายละเอียดเพิ่มเติม',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),

              // Seller Profile Card
              _buildSellerCard(context, state, product, averageRating, isDark),
              const SizedBox(height: 20),

              // Action Buttons (Chat & Favorite or Owner actions)
              if (!isOwner) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text(
                          'ทักแชทคุยกับผู้ขาย',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _openChat(context, state, product),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        side: BorderSide(
                          color: product.isFavorite ? AppTheme.danger : (isDark ? AppTheme.darkBorder : AppTheme.border),
                        ),
                      ),
                      icon: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: product.isFavorite ? AppTheme.danger : null,
                      ),
                      label: Text(
                        product.isFavorite ? 'ถูกใจแล้ว' : 'รายการโปรด',
                        style: TextStyle(
                          color: product.isFavorite ? AppTheme.danger : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => state.toggleFavorite(product.id),
                    ),
                  ],
                ),
              ],

              if (isOwner) _buildOwnerActions(context, state, product, isDark),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile 1-Column Layout
  Widget _buildMobileLayout(
    BuildContext context,
    AppState state,
    dynamic product,
    bool isOwner,
    bool isAdmin,
    double averageRating,
    NumberFormat currencyFormatter,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(context, product, height: 280),
        const SizedBox(height: 16),

        _buildStatusAndConditionTags(product),
        const SizedBox(height: 12),

        Text(
          '฿${currencyFormatter.format(product.price)}',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: 6),

        Text(
          product.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
        ),
        const SizedBox(height: 14),

        _buildSpecBox(context, product, isDark),
        const SizedBox(height: 14),

        const Text(
          'รายละเอียดสินค้า',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          product.description.isNotEmpty ? product.description : 'ไม่มีรายละเอียดเพิ่มเติม',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),

        _buildSellerCard(context, state, product, averageRating, isDark),
        const SizedBox(height: 16),

        if (isAdmin) ...[
          _buildAdminBox(context, state, product, isDark),
          const SizedBox(height: 16),
        ],

        if (isOwner) ...[
          _buildOwnerActions(context, state, product, isDark),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildProductImage(BuildContext context, dynamic product, {required double height}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: height,
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
        if (product.status == 'sold')
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(140),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ขายแล้ว',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusAndConditionTags(dynamic product) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: product.condition == 'new' ? AppTheme.success : const Color(0xFF475569),
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
    );
  }

  Widget _buildSpecBox(BuildContext context, dynamic product, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ข้อมูลสินค้า',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'หมวดหมู่',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${product.category?.icon ?? "📦"} ${product.category?.name ?? "ทั่วไป"}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'สภาพสินค้า',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppTheme.darkTextSecondary : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.conditionLabel,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(BuildContext context, AppState state, dynamic product, double averageRating, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: product.seller.avatarUrl.isNotEmpty ? NetworkImage(product.seller.avatarUrl) : null,
              child: product.seller.avatarUrl.isEmpty ? const Icon(Icons.person, size: 24) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.seller.effectiveName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      if (product.seller.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 15, color: AppTheme.primaryLight),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 15, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${state.getReviewsForSeller(product.seller.id).length} รีวิว)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextSecondary : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SellerProfileScreen(seller: product.seller)),
                );
              },
              child: const Text('ดูร้านค้า', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBox(BuildContext context, AppState state, dynamic product, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🛠️ แผงควบคุมผู้ดูแลระบบ (Admin Controls)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (product.status != 'active')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.success,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('อนุมัติสินค้า', style: TextStyle(fontSize: 12)),
                    onPressed: () {
                      state.approveProduct(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('อนุมัติสินค้าเรียบร้อย')),
                      );
                    },
                  ),
                if (product.status != 'rejected')
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.danger,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('ปฏิเสธ', style: TextStyle(fontSize: 12)),
                    onPressed: () => state.rejectProduct(product.id),
                  ),
                if (product.status != 'suspended')
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.pause_circle_outline, size: 16),
                    label: const Text('ระงับสินค้า', style: TextStyle(fontSize: 12)),
                    onPressed: () => state.suspendProduct(product.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerActions(BuildContext context, AppState state, dynamic product, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? AppTheme.darkBorder : AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'จัดการสินค้าของคุณ',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (product.status != 'sold')
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.done_all, size: 16),
                      label: const Text('ทำเครื่องหมายว่าขายแล้ว', style: TextStyle(fontSize: 12)),
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
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('แก้ไข', style: TextStyle(fontSize: 12)),
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
    );
  }
}
