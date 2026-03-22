import 'package:flutter/material.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';

class ReelsAudioToggleButton extends StatelessWidget {
  const ReelsAudioToggleButton({
    super.key,
    required this.isMuted,
    required this.onPressed,
  });

  final bool isMuted;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.reelsOverlay.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: onPressed,
        splashRadius: 20,
        color: context.colors.reelsForeground,
        tooltip: isMuted ? 'Unmute' : 'Mute',
        icon: Icon(
          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        ),
      ),
    );
  }
}
