import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/responsive.dart';
import '../product/product_detail_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final int roomId;

  const ChatRoomScreen({super.key, required this.roomId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController textCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).markRoomMessagesAsRead(widget.roomId);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (scrollCtrl.hasClients) {
      scrollCtrl.animateTo(
        scrollCtrl.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatter = DateFormat('HH:mm');
    final currencyFormatter = NumberFormat('#,##0', 'th_TH');

    return Consumer<AppState>(
      builder: (context, state, _) {
        final roomList = state.chatRooms.where((r) => r.id == widget.roomId).toList();
        if (roomList.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('ห้องสนทนา')),
            body: const Center(child: Text('ไม่พบห้องแชท')),
          );
        }

        final room = roomList.first;
        final messages = state.getMessagesForRoom(widget.roomId);

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundImage: room.otherUser.avatarUrl.isNotEmpty
                      ? NetworkImage(room.otherUser.avatarUrl)
                      : null,
                  child: room.otherUser.avatarUrl.isEmpty
                      ? const Icon(Icons.person, size: 18)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              room.otherUser.effectiveName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (room.otherUser.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 16, color: AppTheme.primaryLight),
                          ],
                        ],
                      ),
                      const Text(
                        'กำลังใช้งาน',
                        style: TextStyle(fontSize: 11, color: AppTheme.success),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: MaxWidthContainer(
            maxWidth: 900,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Related Product Card Banner if exists
                if (room.relatedProductName != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: InkWell(
                      onTap: () {
                        if (room.relatedProductId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductDetailScreen(productId: room.relatedProductId!),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            if (room.relatedProductImage != null && room.relatedProductImage!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  room.relatedProductImage!,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    room.relatedProductName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  if (room.relatedProductPrice != null)
                                    Text(
                                      '฿${currencyFormatter.format(room.relatedProductPrice)}',
                                      style: const TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),

                const Divider(height: 1),

                // Messages list
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMine = msg.isMine;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          mainAxisAlignment:
                              isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMine) ...[
                              CircleAvatar(
                                radius: 14,
                                backgroundImage: room.otherUser.avatarUrl.isNotEmpty
                                    ? NetworkImage(room.otherUser.avatarUrl)
                                    : null,
                                child: room.otherUser.avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 14)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 400),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isMine ? AppTheme.primary : Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                                    bottomRight: Radius.circular(isMine ? 4 : 16),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(10),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.content,
                                      style: TextStyle(
                                        color: isMine ? Colors.white : AppTheme.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      timeFormatter.format(msg.timestamp),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isMine
                                            ? Colors.white.withAlpha(180)
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Quick Prompt Chips
                Container(
                  color: Colors.white,
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    itemCount: AppConstants.quickChatPrompts.length,
                    separatorBuilder: (context, sepIdx) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final prompt = AppConstants.quickChatPrompts[i];
                      return ActionChip(
                        label: Text(prompt, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          textCtrl.text = prompt;
                          _sendMessage(state);
                        },
                      );
                    },
                  ),
                ),

                // Input Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.image_outlined, color: Colors.grey),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('คุณสามารถส่งรูปภาพหรือรายละเอียดสินค้าได้ทางแชท')),
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: textCtrl,
                            decoration: InputDecoration(
                              hintText: 'พิมพ์ข้อความของคุณ...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            onSubmitted: (_) => _sendMessage(state),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.send_rounded, size: 20),
                          onPressed: () => _sendMessage(state),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendMessage(AppState state) {
    if (textCtrl.text.trim().isEmpty) return;
    state.sendMessage(widget.roomId, textCtrl.text);
    textCtrl.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }
}
