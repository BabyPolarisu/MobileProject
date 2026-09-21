import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../core/theme.dart';

class RoleSwitchBanner extends StatelessWidget {
  const RoleSwitchBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final isAdmin = state.currentUser.isAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF),
      child: Row(
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.school,
            size: 18,
            color: isAdmin ? const Color(0xFFD97706) : AppTheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAdmin
                  ? 'โหมดผู้ดูแลระบบ: ${state.currentUser.effectiveName} (สามารถอนุมัติ/ลบสินค้าได้)'
                  : 'โหมดนักศึกษา: ${state.currentUser.effectiveName}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isAdmin ? const Color(0xFF92400E) : AppTheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const Icon(Icons.swap_horiz, size: 16),
            label: Text(
              isAdmin ? 'สลับเป็นนักศึกษา' : 'สลับเป็นแอดมิน',
              style: const TextStyle(fontSize: 12),
            ),
            onPressed: () => state.switchUserRole(!isAdmin),
          ),
        ],
      ),
    );
  }
}
