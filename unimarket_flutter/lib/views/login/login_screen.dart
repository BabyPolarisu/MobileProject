import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'somchai_ubu');
  final _passwordController = TextEditingController(text: 'somchai1234');
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณากรอกชื่อผู้ใช้และรหัสผ่าน'),
          backgroundColor: AppTheme.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final state = Provider.of<AppState>(context, listen: false);
    final success = await state.loginWithOidc(username, password);
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ยินดีต้อนรับคุณ ${state.currentUser.effectiveName} 🎉'),
          backgroundColor: AppTheme.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เข้าสู่ระบบไม่สำเร็จ ตรวจสอบชื่อผู้ใช้หรือการเชื่อมต่อ OIDC Server'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: MaxWidthContainer(
              maxWidth: 480,
              child: Card(
                elevation: isDark ? 1 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark ? AppTheme.darkBorder : AppTheme.border,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo & Title
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 40,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'UniMarket',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ตลาดนัดออนไลน์มหาวิทยาลัยอุบลราชธานี',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // OIDC Server Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: state.isConnectedToBackend
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: state.isConnectedToBackend
                                  ? const Color(0xFF86EFAC)
                                  : const Color(0xFFFCA5A5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 14,
                                color: state.isConnectedToBackend
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                state.isConnectedToBackend
                                    ? 'OIDC Provider Online (Port 8000)'
                                    : 'OIDC Provider Offline',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: state.isConnectedToBackend
                                      ? const Color(0xFF15803D)
                                      : const Color(0xFFB91C1C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Input Fields
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อผู้ใช้ (Username)',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'รหัสผ่าน (Password)',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        onSubmitted: (_) => _handleLogin(),
                      ),

                      const SizedBox(height: 22),

                      // Login Button
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
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
                                    Icon(Icons.login, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'เข้าสู่ระบบผ่าน OIDC Auth',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Demo accounts quick select
                      Text(
                        '💡 บัญชีสำหรับทดสอบระบบ (Demo Accounts):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ActionChip(
                            avatar: const Icon(Icons.person, size: 16),
                            label: const Text('somchai_ubu (นักศึกษา)'),
                            onPressed: () => _fillAccount('somchai_ubu', 'somchai1234'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.person_2, size: 16),
                            label: const Text('thanaporn_k (นักศึกษา)'),
                            onPressed: () => _fillAccount('thanaporn_k', 'thanaporn1234'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.admin_panel_settings, size: 16),
                            label: const Text('admin (ผู้ดูแลระบบ)'),
                            onPressed: () => _fillAccount('admin', 'admin1234'),
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
    );
  }
}
