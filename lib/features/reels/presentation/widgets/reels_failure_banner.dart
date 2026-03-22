import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_text_styles.dart';

class ReelsFailureBanner extends StatelessWidget {
  const ReelsFailureBanner({
    super.key,
    required this.message,
    this.topOffset = 48,
  });

  final String message;
  final double topOffset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topOffset,
      left: 16,
      right: 16,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.reelsFailureBanner,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            message,
            style: context.appTextStyles.bodySmall.medium.copyWith(
              color: context.colors.reelsForeground,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
