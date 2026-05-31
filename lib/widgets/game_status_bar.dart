import 'package:flutter/material.dart';

class GameStatusBar extends StatelessWidget {
  const GameStatusBar({
    super.key,
    required this.statusText,
    required this.accentColor,
    required this.accentBorderColor,
    required this.remainingSeconds,
    required this.isGameOver,
  });

  final String statusText;
  final Color accentColor;
  final Color accentBorderColor;
  final int remainingSeconds;
  final bool isGameOver;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0D8CA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
              border: Border.all(color: accentBorderColor),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            statusText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D2926),
                ),
          ),
          const SizedBox(width: 12),
          _TimerBadge(
            remainingSeconds: remainingSeconds,
            isGameOver: isGameOver,
          ),
        ],
      ),
    );
  }
}

class _TimerBadge extends StatelessWidget {
  const _TimerBadge({
    required this.remainingSeconds,
    required this.isGameOver,
  });

  final int remainingSeconds;
  final bool isGameOver;

  @override
  Widget build(BuildContext context) {
    final bool isWarning = !isGameOver && remainingSeconds <= 10;
    final Color badgeColor =
        isWarning ? const Color(0xFFFFEBEE) : const Color(0xFFF7EFE2);
    final Color textColor =
        isWarning ? const Color(0xFFC62828) : const Color(0xFF5D4037);
    final String timerText = isGameOver ? '종료' : '$remainingSeconds초';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWarning ? const Color(0xFFEF9A9A) : const Color(0xFFE0D8CA),
        ),
      ),
      child: Text(
        timerText,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
