import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_text_styles.dart';

class ReelsTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ReelsTopAppBar({
    super.key,
    required this.isMuted,
    required this.onAudioToggle,
  });

  final bool isMuted;
  final VoidCallback onAudioToggle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: context.colors.transparent,
      surfaceTintColor: context.colors.transparent,
      titleSpacing: 16,
      title: const _AppBarTitle(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: onAudioToggle,
            splashRadius: 20,
            color: context.colors.reelsForeground,
            tooltip: isMuted ? 'Unmute' : 'Mute',
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            ),
          ),
        ),
      ],
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.reelsOverlay.withValues(alpha: 0.67),
              context.colors.reelsOverlay.withValues(alpha: 0.33),
              context.colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.movie_creation_outlined,
          color: context.colors.reelsForeground,
          size: 22,
        ),
        const SizedBox(width: 8),
        Text(
          'Reels',
          style: context.appTextStyles.titleMedium.bold.copyWith(
            color: context.colors.reelsForeground,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
