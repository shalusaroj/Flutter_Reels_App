import 'package:flutter/material.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:reels_assignment/presentation/theme/app_text_styles.dart';
import 'package:video_player/video_player.dart';

class ReelView extends StatelessWidget {
  const ReelView({
    super.key,
    required this.reel,
    required this.likes,
    required this.isLiked,
    required this.isLikeSyncing,
    required this.controller,
    required this.isLoading,
    required this.isActive,
    required this.onTap,
    required this.onDoubleTap,
    required this.onLikeTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    this.likeAnimationToken,
  });

  final Reel reel;
  final int likes;
  final bool isLiked;
  final bool isLikeSyncing;
  final VideoPlayerController? controller;
  final bool isLoading;
  final bool isActive;
  final int? likeAnimationToken;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback onLikeTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    const likesBottomBaseOffset = 124.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPressStart: (_) => onLongPressStart(),
      onLongPressEnd: (_) => onLongPressEnd(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: context.colors.reelsBackground,
            child: _VideoSurface(
              controller: controller,
              isLoading: isLoading,
              isActive: isActive,
            ),
          ),
          const _BottomGradient(),
          if (likeAnimationToken != null)
            Positioned.fill(
              child: IgnorePointer(
                child: _LikeBurstAnimation(token: likeAnimationToken!),
              ),
            ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 24 + bottomInset,
            child: _ReelMeta(reel: reel),
          ),
          Positioned(
            right: 16,
            bottom: likesBottomBaseOffset + bottomInset,
            child: _LikesColumn(
              likes: likes,
              isLiked: isLiked,
              isSyncing: isLikeSyncing,
              onLikeTap: onLikeTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.controller,
    required this.isLoading,
    required this.isActive,
  });

  final VideoPlayerController? controller;
  final bool isLoading;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final localController = controller;
    if (localController == null || !localController.value.isInitialized) {
      return Center(
        child:
            isLoading
                ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(),
                )
                : const SizedBox.shrink(),
      );
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: localController,
      // Reuse the heavy video subtree; only overlay/progress should refresh.
      child: RepaintBoundary(child: VideoPlayer(localController)),
      builder: (context, value, videoChild) {
        final durationMs = value.duration.inMilliseconds;
        final progress =
            durationMs <= 0
                ? 0.0
                : (value.position.inMilliseconds / durationMs).clamp(0.0, 1.0);
        final showPausedOverlay =
            isActive && !value.isPlaying && !value.isBuffering;
        final aspectRatio =
            value.aspectRatio == 0 ? (9 / 16) : value.aspectRatio;

        return Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: videoChild ?? const SizedBox.shrink(),
              ),
            ),
            if (isActive && value.isBuffering)
              const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(),
                ),
              ),
            if (showPausedOverlay) const Center(child: _PausedPlayIcon()),
            if (isActive)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12 + bottomInset,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    value: progress,
                    color: context.colors.reelsForeground,
                    backgroundColor: context.colors.reelsForeground.withValues(
                      alpha: 0.24,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PausedPlayIcon extends StatelessWidget {
  const _PausedPlayIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: context.colors.reelsOverlay.withValues(alpha: 0.45),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.play_arrow_rounded,
        color: context.colors.reelsForeground,
        size: 34,
      ),
    );
  }
}

class _LikeBurstAnimation extends StatelessWidget {
  const _LikeBurstAnimation({required this.token});

  final int token;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<int>(token),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final scale =
            value < 0.45
                ? 0.7 + (value / 0.45) * 0.55
                : 1.25 - ((value - 0.45) / 0.55) * 0.25;
        final opacity =
            value < 0.75 ? 1.0 : (1 - ((value - 0.75) / 0.25)).clamp(0.0, 1.0);
        return Center(
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(scale: scale, child: child),
          ),
        );
      },
      child: Icon(
        Icons.favorite,
        color: context.colors.reelsForeground,
        size: 96,
      ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              context.colors.transparent,
              context.colors.reelsOverlay.withValues(alpha: 0.65),
            ],
            stops: const [0.55, 1],
          ),
        ),
      ),
    );
  }
}

class _ReelMeta extends StatelessWidget {
  const _ReelMeta({required this.reel});

  final Reel reel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '@${reel.username}',
          style: context.appTextStyles.titleMedium.bold.copyWith(
            color: context.colors.reelsForeground,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          reel.caption,
          style: context.appTextStyles.bodyMedium.copyWith(
            color: context.colors.reelsForeground,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _LikesColumn extends StatelessWidget {
  const _LikesColumn({
    required this.likes,
    required this.isLiked,
    required this.isSyncing,
    required this.onLikeTap,
  });

  final int likes;
  final bool isLiked;
  final bool isSyncing;
  final VoidCallback onLikeTap;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isLiked
            ? context.colors.reelsLikeActive
            : context.colors.reelsForeground;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onLikeTap,
          splashRadius: 22,
          iconSize: 32,
          color: iconColor,
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
        ),
        if (isSyncing)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.8,
              color: context.colors.reelsForegroundMuted,
            ),
          ),
        Text(
          likes.toString(),
          style: context.appTextStyles.bodyMedium.bold.copyWith(
            color: context.colors.reelsForeground,
          ),
        ),
      ],
    );
  }
}
