import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_text_styles.dart';

class ReelsErrorView extends StatelessWidget {
  const ReelsErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.appTextStyles.bodyMedium.copyWith(
                color: context.colors.reelsForegroundMuted,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
