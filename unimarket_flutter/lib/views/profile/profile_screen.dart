import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import '../product/my_listings_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../verification/verification_screen.dart';
import '../report/my_reports_screen.dart';
import '../notifications/notifications_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final bool showAppBar;
  const ProfileScreen({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final user = state.currentUser;
        final myListingsCount = state.myListings.length;
        final wishlistCount = state.wishlistProducts.length;

        return Scaffold(
          appBar: showAppBar
              ? AppBar(
                  title: const Text('โปรไฟล์ของฉัน'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                    ),
                  ],
                )
              : null,
          body: MaxWidthContainer(
            maxWidth: 700,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // User Header Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: user.avatarUrl.isNotEmpty
                                ? NetworkImage(user.avatarUrl)
                                : null,
                            child: user.avatarUrl.isEmpty
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                user.effectiveName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              if (user.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: AppTheme.primaryLight, size: 20),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                          if (user.bio.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              user.bio,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('สินค้าที่ลงขาย', '$myListingsCount ชิ้น'),
                              Container(height: 24, width: 1, color: Colors.grey[300]),
                              _buildStatItem('รายการโปรด', '$wishlistCount ชิ้น'),
                              Container(height: 24, width: 1, color: Colors.grey[300]),
                              _buildStatItem(
                                'สถานะนักศึกษา',
                                user.isVerified ? 'ยืนยันแล้ว ✅' : 'รอยืนยัน ⏳',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu Items
                  Card(
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.inventory_2_outlined,
                          title: 'สินค้าของฉัน (My Listings)',
                          subtitle: '$myListingsCount รายการ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyListingsScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuTile(
                          icon: Icons.favorite_border,
                          title: 'รายการโปรด (Wishlist)',
                          subtitle: '$wishlistCount รายการ',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WishlistScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuTile(
                          icon: Icons.badge_outlined,
                          title: 'ยืนยันตัวตนด้วยบัตรนักศึกษา',
                          subtitle: user.isVerified ? 'ผ่านการอนุมัติแล้ว' : 'ส่งหลักฐานบัตรนักศึกษา',
                          trailing: user.isVerified
                              ? const Icon(Icons.check_circle, color: AppTheme.success, size: 20)
                              : null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const VerificationScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuTile(
                          icon: Icons.notifications_none_outlined,
                          title: 'การแจ้งเตือน (Notifications)',
                          subtitle: '${state.unreadNotificationsCount} รายการใหม่',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        _buildMenuTile(
                          icon: Icons.report_problem_outlined,
                          title: 'ประวัติการรายงานปัญหา (My Reports)',
                          subtitle: 'ตรวจสอบสถานะเรื่องที่แจ้ง',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyReportsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Admin & Developer tools
                  Card(
                    child: Column(
                      children: [
                        if (user.isAdmin) ...[
                          _buildMenuTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'แดชบอร์ดผู้ดูแลระบบ (Admin Dashboard)',
                            subtitle: 'อนุมัติสินค้าและจัดการรายงานปัญหา',
                            color: Colors.amber[800],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1),
                        ],
                        _buildMenuTile(
                          icon: Icons.swap_horiz,
                          title: user.isAdmin ? 'สลับเป็นบัญชีนักศึกษาทั่วไป' : 'สลับเป็นบัญชีผู้ดูแลระบบ (Admin)',
                          subtitle: 'เพื่อทดสอบฟังก์ชันแอดมินและการอนุมัติ',
                          onTap: () => state.switchUserRole(!user.isAdmin),
                        ),
                        const Divider(height: 1),
                        _buildMenuTile(
                          icon: state.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          title: 'ธีมของระบบ (Theme)',
                          subtitle: state.isDarkMode ? 'โหมดมืด (Dark Mode)' : 'โหมดสว่าง (Light Mode)',
                          trailing: Switch(
                            value: state.isDarkMode,
                            onChanged: (_) => state.toggleDarkMode(),
                          ),
                          onTap: () => state.toggleDarkMode(),
                        ),
                        const Divider(height: 1),
                        _buildMenuTile(
                          icon: Icons.logout,
                          title: 'ออกจากระบบ (OIDC Sign Out)',
                          subtitle: 'ล้างโทเค็นเซสชันและกลับสู่หน้าเข้าสู่ระบบ',
                          color: AppTheme.danger,
                          trailing: const Icon(Icons.exit_to_app, color: AppTheme.danger, size: 20),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('ยืนยันออกจากระบบ'),
                                content: const Text('คุณต้องการออกจากระบบและล้างโทเค็นเซสชัน OIDC หรือไม่?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('ยกเลิก'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      state.logout();
                                    },
                                    child: const Text('ออกจากระบบ'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
