import 'dart:async';

import 'package:flutter/material.dart';

abstract final class StatusNotice {
  static void show(
    BuildContext context, {
    required bool success,
    required String message,
  }) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Status notice',
      barrierColor: Colors.black.withValues(alpha: 0.48),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, _) =>
          _StatusNoticeDialog(success: success, message: message),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.94,
            end: 1,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }
}

class _StatusNoticeDialog extends StatefulWidget {
  const _StatusNoticeDialog({required this.success, required this.message});

  final bool success;
  final String message;

  @override
  State<_StatusNoticeDialog> createState() => _StatusNoticeDialogState();
}

class _StatusNoticeDialogState extends State<_StatusNoticeDialog> {
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _dismissTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xF022293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.success
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              key: ValueKey(
                widget.success
                    ? 'status_notice_success'
                    : 'status_notice_failure',
              ),
              size: 52,
              color: Colors.white,
            ),
            const SizedBox(height: 14),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
