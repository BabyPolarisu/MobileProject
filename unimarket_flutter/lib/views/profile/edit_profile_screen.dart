import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addrCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController avatarCtrl;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    nameCtrl = TextEditingController(text: user.displayName);
    phoneCtrl = TextEditingController(text: user.phoneNumber);
    addrCtrl = TextEditingController(text: user.address);
    bioCtrl = TextEditingController(text: user.bio);
    avatarCtrl = TextEditingController(text: user.avatarUrl);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addrCtrl.dispose();
    bioCtrl.dispose();
    avatarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('แก้ไขโปรไฟล์'),
      ),
      body: MaxWidthContainer(
        maxWidth: 600,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundImage: avatarCtrl.text.isNotEmpty
                            ? NetworkImage(avatarCtrl.text)
                            : null,
                        child: avatarCtrl.text.isEmpty
                            ? const Icon(Icons.person, size: 46)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.primary,
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text('URL รูปโปรไฟล์', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: avatarCtrl,
                  decoration: const InputDecoration(hintText: 'https://example.com/avatar.jpg'),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),

                const Text('ชื่อที่แสดง (Display Name) *', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  validator: (v) => v == null || v.trim().isEmpty ? 'กรุณาระบุชื่อ' : null,
                ),
                const SizedBox(height: 16),

                const Text('เบอร์โทรศัพท์ติดต่อ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                const Text('สถานที่นัดรับหรือที่อยู่ประจำ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: addrCtrl,
                  decoration: const InputDecoration(hintText: 'เช่น หอพักนักศึกษา, คณะวิทยาศาสตร์ ม.อุบล'),
                ),
                const SizedBox(height: 16),

                const Text('ประวัติโดยย่อ (Bio)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: bioCtrl,
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      state.updateProfile(
                        displayName: nameCtrl.text.trim(),
                        phoneNumber: phoneCtrl.text.trim(),
                        address: addrCtrl.text.trim(),
                        bio: bioCtrl.text.trim(),
                        avatarUrl: avatarCtrl.text.trim(),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('บันทึกข้อมูลโปรไฟล์เรียบร้อยแล้ว'), backgroundColor: AppTheme.success),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('บันทึกข้อมูล', style: TextStyle(fontSize: 16)),
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
