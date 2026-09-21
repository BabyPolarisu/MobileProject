import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class ProductFormScreen extends StatefulWidget {
  final ProductModel? productToEdit;

  const ProductFormScreen({super.key, this.productToEdit});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController descCtrl;
  late TextEditingController imageCtrl;
  CategoryModel? selectedCategory;
  String selectedCondition = 'used';

  final List<String> samplePhotos = [
    'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop', // book
    'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=600&auto=format&fit=crop', // ipad
    'https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?w=600&auto=format&fit=crop', // shirt
    'https://images.unsplash.com/photo-1525966222134-fcfa99b8ae77?w=600&auto=format&fit=crop', // shoes
    'https://images.unsplash.com/photo-1584992236310-6edddc08acff?w=600&auto=format&fit=crop', // fridge
    'https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=600&auto=format&fit=crop', // calculator
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.productToEdit;
    nameCtrl = TextEditingController(text: edit?.name ?? '');
    priceCtrl = TextEditingController(text: edit != null ? edit.price.toStringAsFixed(0) : '');
    descCtrl = TextEditingController(text: edit?.description ?? '');
    imageCtrl = TextEditingController(text: edit?.imageUrl ?? samplePhotos.first);
    selectedCondition = edit?.condition ?? 'used';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isEditing = widget.productToEdit != null;

    if (selectedCategory == null && state.categories.isNotEmpty) {
      if (isEditing && widget.productToEdit?.category != null) {
        selectedCategory = state.categories.firstWhere(
          (c) => c.id == widget.productToEdit!.category!.id,
          orElse: () => state.categories.first,
        );
      } else {
        selectedCategory = state.categories.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'แก้ไขข้อมูลสินค้า' : 'ลงขายสินค้าใหม่'),
      ),
      body: MaxWidthContainer(
        maxWidth: 700,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Preview
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ValueListenableBuilder<TextEditingValue>(
                          valueListenable: imageCtrl,
                          builder: (context, value, _) {
                            if (value.text.isEmpty) {
                              return const Center(child: Text('ไม่มีรูปภาพตัวอย่าง'));
                            }
                            return Image.network(
                              value.text,
                              fit: BoxFit.cover,
                              errorBuilder: (context, err, stack) => const Center(
                                child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'เลือกรูปภาพตัวอย่างเร็ว หรือวางลิงก์รูปภาพของคุณ:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: samplePhotos.length,
                          separatorBuilder: (context, sepIdx) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final photo = samplePhotos[index];
                            return InkWell(
                              onTap: () => setState(() => imageCtrl.text = photo),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: imageCtrl.text == photo ? AppTheme.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(photo, fit: BoxFit.cover),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Image URL input
                const Text('URL รูปภาพสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(
                    hintText: 'https://example.com/image.jpg',
                    prefixIcon: Icon(Icons.link),
                  ),
                  onChanged: (val) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Product Name
                const Text('ชื่อสินค้า *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    hintText: 'เช่น หนังสือแคลคูลัส 1, iPad Air 5 สภาพสวย',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาระบุชื่อสินค้า';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category & Price Row
                Row(
                  children: [
                    // Category
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('หมวดหมู่ *', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<CategoryModel>(
                            initialValue: selectedCategory,
                            items: state.categories.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Row(
                                  children: [
                                    Text(c.icon),
                                    const SizedBox(width: 8),
                                    Text(c.name, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => selectedCategory = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Price
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ราคา (บาท) *', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              prefixText: '฿ ',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณาระบุราคา';
                              }
                              if (double.tryParse(value.trim()) == null) {
                                return 'ตัวเลขเท่านั้น';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Condition
                const Text('สภาพสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('📦 มือสอง (Used)'),
                      selected: selectedCondition == 'used',
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: selectedCondition == 'used' ? Colors.white : AppTheme.textPrimary,
                        fontWeight: selectedCondition == 'used' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => selectedCondition = 'used');
                      },
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: const Text('✨ มือหนึ่ง (New)'),
                      selected: selectedCondition == 'new',
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: selectedCondition == 'new' ? Colors.white : AppTheme.textPrimary,
                        fontWeight: selectedCondition == 'new' ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) setState(() => selectedCondition = 'new');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                const Text('รายละเอียดเพิ่มเติม *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'ระบุสภาพสินค้า การใช้งาน จุดนัดรับของ หรือเงื่อนไขเพิ่มเติม...',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'กรุณาระบุรายละเอียดสินค้า';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      final price = double.parse(priceCtrl.text.trim());

                      if (isEditing) {
                        final updated = widget.productToEdit!.copyWith(
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          price: price,
                          condition: selectedCondition,
                          imageUrl: imageCtrl.text.trim(),
                          category: selectedCategory,
                          updatedAt: DateTime.now(),
                        );
                        state.updateProduct(updated);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('บันทึกการแก้ไขสินค้าเรียบร้อย'), backgroundColor: AppTheme.success),
                        );
                      } else {
                        state.addProduct(
                          name: nameCtrl.text.trim(),
                          description: descCtrl.text.trim(),
                          price: price,
                          condition: selectedCondition,
                          category: selectedCategory!,
                          imageUrl: imageCtrl.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.currentUser.isAdmin
                                  ? 'โพสต์สินค้าสำเร็จและวางขายทันที'
                                  : 'ลงขายสินค้าเรียบร้อย รอแอดมินอนุมัติ',
                            ),
                            backgroundColor: AppTheme.success,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      isEditing ? 'บันทึกการแก้ไข' : 'ยืนยันการลงขายสินค้า',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
