import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../core/theme.dart';
import '../core/responsive.dart';
import 'home/home_screen.dart';
import 'chat/chat_list_screen.dart';
import 'wishlist/wishlist_screen.dart';
import 'profile/profile_screen.dart';
import 'product/product_form_screen.dart';
import 'notifications/notifications_screen.dart';
import 'widgets/role_switch_banner.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    ChatListScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isDesktop ? 105 : 95),
        child: Column(
          children: [
            const RoleSwitchBanner(),
            if (isDesktop)
              _buildDesktopTopBar(context, state)
            else
              _buildMobileTopBar(context, state),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      floatingActionButton: !isDesktop && _currentIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('ลงขาย'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                );
              },
            )
          : null,
      bottomNavigationBar: !isDesktop
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront, color: AppTheme.primary),
                  label: 'หน้าแรก',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: state.unreadMessagesCount > 0,
                    label: Text(state.unreadMessagesCount.toString()),
                    child: const Icon(Icons.chat_bubble_outline),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: state.unreadMessagesCount > 0,
                    label: Text(state.unreadMessagesCount.toString()),
                    child: const Icon(Icons.chat_bubble, color: AppTheme.primary),
                  ),
                  label: 'แชท',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: state.wishlistProducts.isNotEmpty,
                    label: Text(state.wishlistProducts.length.toString()),
                    child: const Icon(Icons.favorite_border),
                  ),
                  selectedIcon: const Icon(Icons.favorite, color: AppTheme.danger),
                  label: 'รายการโปรด',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppTheme.primary),
                  label: 'โปรไฟล์',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildDesktopTopBar(BuildContext context, AppState state) {
    return Container(
      height: 65,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: MaxWidthContainer(
        maxWidth: 1200,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            // Logo
            InkWell(
              onTap: () => setState(() => _currentIndex = 0),
              child: const Row(
                children: [
                  Text('🎓', style: TextStyle(fontSize: 26)),
                  SizedBox(width: 8),
                  Text(
                    'UniMarket',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),

            // Navigation Links
            _desktopNavLink('ตลาดสินค้า', 0, Icons.storefront),
            _desktopNavLink('ข้อความแชท', 1, Icons.chat_bubble_outline, badgeCount: state.unreadMessagesCount),
            _desktopNavLink('รายการโปรด', 2, Icons.favorite_border, badgeCount: state.wishlistProducts.length),
            _desktopNavLink('โปรไฟล์ของฉัน', 3, Icons.person_outline),

            const Spacer(),

            // Post Product Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('ลงขายสินค้า', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductFormScreen()),
                );
              },
            ),
            const SizedBox(width: 12),

            // Notifications
            IconButton(
              icon: Badge(
                isLabelVisible: state.unreadNotificationsCount > 0,
                label: Text(state.unreadNotificationsCount.toString()),
                child: const Icon(Icons.notifications_none),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                );
              },
            ),
            const SizedBox(width: 8),

            // Avatar Chip
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => setState(() => _currentIndex = 3),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: state.currentUser.avatarUrl.isNotEmpty
                          ? NetworkImage(state.currentUser.avatarUrl)
                          : null,
                      child: state.currentUser.avatarUrl.isEmpty
                          ? const Icon(Icons.person, size: 16)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.currentUser.effectiveName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktopNavLink(String label, int index, IconData icon, {int badgeCount = 0}) {
    final isSelected = _currentIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextButton.icon(
        style: TextButton.styleFrom(
          foregroundColor: isSelected ? AppTheme.primary : AppTheme.textSecondary,
          backgroundColor: isSelected ? AppTheme.primary.withAlpha(20) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Badge(
          isLabelVisible: badgeCount > 0,
          label: Text(badgeCount.toString()),
          child: Icon(icon, size: 18),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
        onPressed: () => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildMobileTopBar(BuildContext context, AppState state) {
    return Container(
      height: 55,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(
            children: [
              Text('🎓', style: TextStyle(fontSize: 22)),
              SizedBox(width: 6),
              Text(
                'UniMarket',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Badge(
                  isLabelVisible: state.unreadNotificationsCount > 0,
                  label: Text(state.unreadNotificationsCount.toString()),
                  child: const Icon(Icons.notifications_none),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
