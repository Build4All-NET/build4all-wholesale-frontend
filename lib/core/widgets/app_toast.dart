import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/app_theme_tokens.dart';
import '../utils/app_error_mapper.dart';

enum AppToastType { success, error, info, warning }

class AppToast {
  static OverlayEntry? _currentToast;
  static Timer? _timer;

  static void success(BuildContext context, Object message) {
    _show(context, message, type: AppToastType.success);
  }

  static void error(BuildContext context, Object error) {
    _show(context, error, type: AppToastType.error);
  }

  static void info(BuildContext context, Object message) {
    _show(context, message, type: AppToastType.info);
  }

  static void warning(BuildContext context, Object message) {
    _show(context, message, type: AppToastType.warning);
  }

  static void _show(
    BuildContext context,
    Object message, {
    required AppToastType type,
  }) {
    final cleanMessage = AppErrorMapper.toMessage(message).trim();
    if (cleanMessage.isEmpty) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Color backgroundColor;
    final Color foregroundColor = Colors.white;
    final IconData icon;

    switch (type) {
      case AppToastType.success:
        backgroundColor = colorScheme.primary;
        icon = Icons.check_circle_outline;
        break;
      case AppToastType.error:
        backgroundColor = AppThemeTokens.error;
        icon = Icons.error_outline;
        break;
      case AppToastType.info:
        backgroundColor = colorScheme.primary;
        icon = Icons.info_outline;
        break;
      case AppToastType.warning:
        backgroundColor = const Color(0xFFF59E0B);
        icon = Icons.warning_amber_rounded;
        break;
    }

    _removeCurrentToast();

    final overlay = Overlay.of(context, rootOverlay: true);
    final mediaQuery = MediaQuery.of(context);

    _currentToast = OverlayEntry(
      builder: (_) {
        return Positioned(
          left: 16,
          right: 16,
          bottom: mediaQuery.padding.bottom + 16,
          child: _ToastOverlayCard(
            message: cleanMessage,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            icon: icon,
          ),
        );
      },
    );

    overlay.insert(_currentToast!);
    _timer = Timer(const Duration(seconds: 3), _removeCurrentToast);
  }

  static void _removeCurrentToast() {
    _timer?.cancel();
    _timer = null;
    _currentToast?.remove();
    _currentToast = null;
  }
}

class _ToastOverlayCard extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  const _ToastOverlayCard({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  @override
  State<_ToastOverlayCard> createState() => _ToastOverlayCardState();
}

class _ToastOverlayCardState extends State<_ToastOverlayCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      widget.icon,
                      color: widget.foregroundColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: widget.foregroundColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}