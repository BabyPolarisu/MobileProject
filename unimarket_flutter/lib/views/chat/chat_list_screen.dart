import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/responsive.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatelessWidget {
  final bool showAppBar;
  const ChatListScreen({super.key, this.showAppBar = false});

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('ข้อความแชท (Inbox)'),
            )
          : null,
      body: Consumer<AppState>(
        builder: (context, state, _) {
          final rooms = state.chatRooms;

          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('ยังไม่มีประวัติการสนทนา', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('กด "ทักแชทคุยกับผู้ขาย" ในหน้ารายละเอียดสินค้าเพื่อเริ่มคุย', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            );
          }

          return MaxWidthContainer(
            maxWidth: 800,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: rooms.length,
              separatorBuilder: (context, sepIdx) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = rooms[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage: room.otherUser.avatarUrl.isNotEmpty
                            ? NetworkImage(room.otherUser.avatarUrl)
                            : null,
                        child: room.otherUser.avatarUrl.isEmpty
                            ? const Icon(Icons.person, size: 26)
                            : null,
                      ),
                      if (room.otherUser.isVerified)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(Icons.verified, size: 16, color: AppTheme.primaryLight),
                        ),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.otherUser.effectiveName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      Text(
                        timeFormatter.format(room.lastMessageTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: room.unreadCount > 0 ? AppTheme.textPrimary : Colors.grey[600],
                            fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (room.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(roomId: room.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
