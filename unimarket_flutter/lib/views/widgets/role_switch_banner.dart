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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark
          ? (isAdmin ? const Color(0xFF451A03) : const Color(0xFF0F172A))
          : (isAdmin ? const Color(0xFFFEF3C7) : const Color(0xFFEFF6FF)),
      child: Row(
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.school,
            size: 18,
            color: isAdmin ? const Color(0xFFD97706) : AppTheme.primaryLight,
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
                color: isDark
                    ? (isAdmin ? const Color(0xFFFDE68A) : const Color(0xFF93C5FD))
                    : (isAdmin ? const Color(0xFF92400E) : AppTheme.primary),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => state.checkBackendConnection(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: state.isConnectedToBackend ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.isConnectedToBackend ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: state.isConnectedToBackend ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    state.isConnectedToBackend ? 'Django Online' : 'Django Offline',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: state.isConnectedToBackend ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.sync,
                    size: 13,
                    color: state.isConnectedToBackend ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
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
