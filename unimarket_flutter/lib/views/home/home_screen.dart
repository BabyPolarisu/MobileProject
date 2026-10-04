import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import '../widgets/product_card.dart';
import '../product/product_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchCtrl = TextEditingController();

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final products = state.filteredProducts;
        final isDesktop = Responsive.isDesktop(context);
        final isTablet = Responsive.isTablet(context);
        final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Sliver App Bar with Search Field
              SliverToBoxAdapter(
                child: MaxWidthContainer(
                  maxWidth: 1200,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Search Input
                      TextField(
                        controller: searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'ค้นหาสินค้า เช่น หนังสือเรียน, iPad, เสื้อผ้า...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                          suffixIcon: searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    searchCtrl.clear();
                                    state.setSearchQuery('');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (val) => state.setSearchQuery(val),
                      ),
                      if (!state.isConnectedToBackend) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF451A03)
                                : Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFFB45309)
                                  : Colors.amber.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cloud_off_rounded, size: 20, color: Color(0xFFD97706)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  state.isSimulatedOffline
                                      ? 'โหมดจำลองออฟไลน์: กำลังแสดงข้อมูลแคชในเครื่อง (ระบบจัดการ Error Handling ทำงานสมบูรณ์)'
                                      : 'โหมดออฟไลน์: ไม่สามารถติดต่อ Django Backend (Port 8000) ได้ กำลังแสดงข้อมูลแคชในเครื่อง',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFF92400E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => state.checkBackendConnection(),
                                child: Text(
                                  'ลองใหม่',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFFFDE68A)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Hero Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E3A8A).withAlpha(60),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(50),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      '🎓 ตลาดนัดนักศึกษา มหาวิทยาลัย',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'ส่งต่อของใช้ ราคาประหยัด นัดรับง่ายในมอ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'ปลอดภัยด้วยระบบยืนยันตัวตนนักศึกษา ตรวจสอบได้ทุกชิ้น',
                                    style: TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accent,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.add_circle_outline),
                                    label: const Text('ลงขายสินค้าฟรี'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            if (!Responsive.isMobile(context))
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text('🛍️', style: TextStyle(fontSize: 72)),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Category Horizontal Scroll List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'หมวดหมู่สินค้า',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (state.selectedCategory != null)
                            TextButton(
                              onPressed: () => state.selectCategory(null),
                              child: const Text('ล้างการเลือก'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.categories.length + 1,
                          separatorBuilder: (context, sepIdx) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isSelected = state.selectedCategory == null;
                              return ChoiceChip(
                                label: const Text('ทั้งหมด 🌟'),
                                selected: isSelected,
                                selectedColor: AppTheme.primary,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                                onSelected: (_) => state.selectCategory(null),
                              );
                            }
                            final cat = state.categories[index - 1];
                            final isSelected = state.selectedCategory?.id == cat.id;
                            return ChoiceChip(
                              avatar: Text(cat.icon),
                              label: Text(cat.name),
                              selected: isSelected,
                              selectedColor: AppTheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) => state.selectCategory(isSelected ? null : cat),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Condition Filter Chips
                      Row(
                        children: [
                          const Text('สภาพ: ', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(width: 6),
                          FilterChip(
                            label: const Text('✨ มือหนึ่ง'),
                            selected: state.selectedCondition == 'new',
                            onSelected: (val) => state.setConditionFilter(val ? 'new' : null),
                          ),
                          const SizedBox(width: 6),
                          FilterChip(
                            label: const Text('📦 มือสอง'),
                            selected: state.selectedCondition == 'used',
                            onSelected: (val) => state.setConditionFilter(val ? 'used' : null),
                          ),
                          const Spacer(),
                          Text(
                            'พบ ${products.length} รายการ',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Product Grid
              if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded, size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('ไม่พบสินค้าที่ตรงตามเงื่อนไขค้นหา', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            searchCtrl.clear();
                            state.setSearchQuery('');
                            state.selectCategory(null);
                            state.setConditionFilter(null);
                          },
                          child: const Text('ล้างตัวกรองทั้งหมด'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child: MaxWidthContainer(
                      maxWidth: 1200,
                      padding: EdgeInsets.zero,
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.68,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return ProductCard(product: products[index]);
                        },
                      ),
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}
