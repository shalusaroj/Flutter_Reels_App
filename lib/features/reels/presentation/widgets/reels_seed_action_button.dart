import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_text_styles.dart';

class ReelsSeedActionButton extends StatelessWidget {
  const ReelsSeedActionButton({
    super.key,
    required this.isSeeding,
    required this.onPressed,
  });

  final bool isSeeding;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: isSeeding ? null : onPressed,
      backgroundColor: context.colors.reelsForeground.withValues(alpha: 0.12),
      foregroundColor: context.colors.reelsForeground,
      icon:
          isSeeding
              ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.colors.reelsForeground,
                ),
              )
              : const Icon(Icons.cloud_upload_outlined),
      label: Text(
        isSeeding ? 'Seeding...' : 'Seed Demo Data',
        style: context.appTextStyles.bodySmall.semiBold.copyWith(
          color: context.colors.reelsForeground,
        ),
      ),
    );
  }
}
