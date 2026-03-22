import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_text_styles.dart';

class ReelsEmptyView extends StatelessWidget {
  const ReelsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No reels found in Firestore.',
        style: context.appTextStyles.titleMedium.copyWith(
          color: context.colors.reelsForegroundMuted,
        ),
      ),
    );
  }
}
