import 'dart:ui';
import 'package:flutter/material.dart';

class ModalUtils {
  /// Displays a modal popup that complies with the SRS constraint of popping open within 300 milliseconds.
  /// Uses a 250ms transition duration to safely fall within limits while appearing smooth.
  static Future<T?> showCustomModal<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool dismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: builder(context),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation, 
              curve: Curves.easeOutCubic,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }
}
