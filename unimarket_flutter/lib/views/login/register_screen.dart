import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final username = _usernameController.text.trim();
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);
    final state = Provider.of<AppState>(context, listen: false);

    final res = await state.register(
      username: username,
      displayName: displayName,
      email: email,
      phoneNumber: phone,
      password: password,
    );

    if (!mounted) return;

    if (res['success'] == true) {
      // Auto login with real OIDC credentials immediately
      final loginSuccess = await state.loginWithOidc(username, password);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (loginSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('สมัครสมาชิกและเข้าสู่ระบบ OIDC สำเร็จ ยินดีต้อนรับคุณ $displayName 🎉'),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context); // Return from register screen, state.isAuthenticated will show MainNavigation
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('สมัครสมาชิกสำเร็จแล้ว กรุณาเข้าสู่ระบบด้วยชื่อผู้ใช้และรหัสผ่านของคุณ'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      setState(() => _isLoading = false);
      final errorMsg = res['error']?.toString() ?? 'การสมัครสมาชิกล้มเหลว';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิกใหม่'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: MaxWidthContainer(
              maxWidth: 520,
              child: Card(
                elevation: isDark ? 2 : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.border,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon & Title
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(25),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.app_registration_rounded,
                              size: 40,
                              color: AppTheme.primaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'ลงทะเบียนผู้ใช้งานใหม่',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'ตลาดนัดออนไลน์นักศึกษา มหาวิทยาลัยอุบลราชธานี',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // UBU Email Notice Banner
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E3A8A).withAlpha(50) : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? const Color(0xFF3B82F6).withAlpha(70) : const Color(0xFFBFDBFE),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_user_rounded, color: AppTheme.primaryLight, size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'ระบบสงวนสิทธิ์เฉพาะนักศึกษาและบุคลากร ม.อุบล โดยต้องใช้อีเมล @ubu.ac.th ในการสมัครเท่านั้น',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryLight,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อผู้ใช้ (Username) *',
                            hintText: 'เช่น somchai_k (ภาษาอังกฤษหรือตัวเลข)',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่อผู้ใช้';
                            }
                            if (value.trim().length < 3) {
                              return 'ชื่อผู้ใช้ต้องมีความยาวอย่างน้อย 3 ตัวอักษร';
                            }
                            if (RegExp(r'[^a-zA-Z0-9_]').hasMatch(value.trim())) {
                              return 'ชื่อผู้ใช้ต้องเป็นตัวอักษรภาษาอังกฤษ ตัวเลข หรือ _ เท่านั้น';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Display Name
                        TextFormField(
                          controller: _displayNameController,
                          decoration: const InputDecoration(
                            labelText: 'ชื่อ-นามสกุล / ชื่อที่แสดง *',
                            hintText: 'เช่น สมชาย เรียนดี',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกชื่อ-นามสกุลสำหรับแสดงบนโปรไฟล์';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email (Strictly @ubu.ac.th)
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'อีเมลมหาวิทยาลัย (@ubu.ac.th) *',
                            hintText: 'xxxxxxxx@ubu.ac.th',
                            helperText: 'บังคับใช้อีเมลสถาบันลงท้ายด้วย @ubu.ac.th',
                            prefixIcon: Icon(Icons.alternate_email_rounded),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกอีเมลมหาวิทยาลัย';
                            }
                            final clean = value.trim().toLowerCase();
                            if (!clean.endsWith('@ubu.ac.th')) {
                              return 'กรุณาใช้อีเมล @ubu.ac.th เท่านั้น (เช่น somchai.c@ubu.ac.th)';
                            }
                            if (clean == '@ubu.ac.th' || clean.length < 11) {
                              return 'รูปแบบอีเมลไม่ถูกต้อง';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Phone Number (Optional)
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'เบอร์โทรศัพท์ (สำหรับนัดรับสินค้า)',
                            hintText: 'เช่น 089-123-4567',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'รหัสผ่าน (Password) *',
                            hintText: 'อย่างน้อย 6 ตัวอักษร',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณากรอกรหัสผ่าน';
                            }
                            if (value.trim().length < 6) {
                              return 'รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'ยืนยันรหัสผ่าน *',
                            hintText: 'กรอกรหัสผ่านอีกครั้งให้ตรงกัน',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'กรุณายืนยันรหัสผ่าน';
                            }
                            if (value.trim() != _passwordController.text.trim()) {
                              return 'รหัสผ่านทั้งสองช่องไม่ตรงกัน';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _handleRegister(),
                        ),

                        const SizedBox(height: 28),

                        // Register Submit Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'ยืนยันการสมัครสมาชิก',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Back to Login link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'มีบัญชีผู้ใช้อยู่แล้ว? ',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'เข้าสู่ระบบที่นี่',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppTheme.primaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
