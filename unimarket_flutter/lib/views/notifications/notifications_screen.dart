import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('การแจ้งเตือน (Notifications)'),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).markNotificationsAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('อ่านการแจ้งเตือนทั้งหมดแล้ว')),
              );
            },
            child: const Text('อ่านทั้งหมด'),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final items = state.notifications;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('ไม่มีการแจ้งเตือนในขณะนี้', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return MaxWidthContainer(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (context, sepIdx) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = items[index];
                return Container(
                  color: notif.isRead ? Colors.transparent : Colors.blue.withAlpha(15),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: notif.isRead ? Colors.grey[200] : AppTheme.primary.withAlpha(30),
                      child: Icon(
                        Icons.notifications_active_outlined,
                        color: notif.isRead ? Colors.grey : AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd/MM HH:mm').format(notif.createdAt),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        notif.message,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
