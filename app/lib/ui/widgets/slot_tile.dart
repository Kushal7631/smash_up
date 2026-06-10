import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/slot.dart';

class SlotTile extends StatelessWidget {
  final Slot slot;
  final int? currentUserId;
  final VoidCallback onTap;

  const SlotTile({
    super.key,
    required this.slot,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMyBooking =
        slot.isBooked && slot.bookedBy != null && slot.bookedBy == currentUserId;

    Color bgColor;
    Color textColor;
    Color borderColor;

    if (isMyBooking) {
      bgColor = AppColors.primary.withValues(alpha: 0.12);
      textColor = AppColors.primary;
      borderColor = AppColors.primary;
    } else if (slot.isBooked) {
      bgColor = AppColors.error.withValues(alpha: 0.08);
      textColor = AppColors.error.withValues(alpha: 0.6);
      borderColor = AppColors.error.withValues(alpha: 0.3);
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.08);
      textColor = AppColors.success;
      borderColor = AppColors.success.withValues(alpha: 0.4);
    }

    return GestureDetector(
      onTap: (!slot.isBooked) ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.displayTime,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 3),
            if (isMyBooking)
              Icon(Icons.check_circle, size: 14, color: AppColors.primary)
            else if (slot.isBooked)
              Icon(Icons.block, size: 14, color: AppColors.error.withValues(alpha: 0.5))
            else
              Text(
                'Book',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
