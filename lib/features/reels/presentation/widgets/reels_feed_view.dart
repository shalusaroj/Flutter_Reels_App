import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reel_view.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_failure_banner.dart';
import 'package:reels_assignment/features/reels/presentation/widgets/reels_page_scroll_physics.dart';
import 'package:reels_assignment/presentation/theme/app_colors_extension.dart';
import 'package:video_player/video_player.dart';

class ReelsFeedView extends StatelessWidget {
  const ReelsFeedView({
    super.key,
    required this.pageController,
    required this.reels,
    required this.controllers,
    required this.loadingIndexes,
    required this.likeAnimationTokens,
    required this.likeCounts,
    required this.likedReelIds,
    required this.syncingReelIds,
    required this.isLoadingMore,
    required this.activeIndex,
    required this.onPageChanged,
    required this.onScrollStart,
    required this.onScrollEnd,
    required this.onReelTap,
    required this.onReelDoubleTap,
    required this.onReelLikeTap,
    required this.onReelLongPressStart,
    required this.onReelLongPressEnd,
    this.failureMessage,
  });

  final PageController pageController;
  final List<Reel> reels;
  final Map<int, VideoPlayerController> controllers;
  final Set<int> loadingIndexes;
  final Map<int, int> likeAnimationTokens;
  final Map<String, int> likeCounts;
  final Set<String> likedReelIds;
  final Set<String> syncingReelIds;
  final bool isLoadingMore;
  final int activeIndex;
  final String? failureMessage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onScrollStart;
  final VoidCallback onScrollEnd;
  final ValueChanged<int> onReelTap;
  final ValueChanged<Reel> onReelLikeTap;
  final ValueChanged<int> onReelLongPressStart;
  final ValueChanged<int> onReelLongPressEnd;
  final void Function(int index, Reel reel) onReelDoubleTap;

  @override
  Widget build(BuildContext context) {
    final mediaPadding = MediaQuery.paddingOf(context);
    final bottomInset = mediaPadding.bottom;
    final topInset = mediaPadding.top;
    final topControlsOffset = topInset + kToolbarHeight + 10;

    return Stack(
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification ||
                (notification is UserScrollNotification &&
                    notification.direction != ScrollDirection.idle)) {
              onScrollStart();
            }

            if (notification is ScrollEndNotification) {
              onScrollEnd();
            }

            return false;
          },
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            allowImplicitScrolling: true,
            physics: const ReelsPageScrollPhysics(),
            itemCount: reels.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              final reel = reels[index];
              final resolvedLikes = likeCounts[reel.id] ?? reel.likes;
              final isLiked = likedReelIds.contains(reel.id);
              final isLikeSyncing = syncingReelIds.contains(reel.id);
              return ReelView(
                reel: reel,
                likes: resolvedLikes,
                isLiked: isLiked,
                isLikeSyncing: isLikeSyncing,
                controller: index == activeIndex ? controllers[index] : null,
                isLoading: index == activeIndex && loadingIndexes.contains(index),
                isActive: index == activeIndex,
                likeAnimationToken: likeAnimationTokens[index],
                onTap: () => onReelTap(index),
                onDoubleTap: () => onReelDoubleTap(index, reel),
                onLikeTap: () => onReelLikeTap(reel),
                onLongPressStart: () => onReelLongPressStart(index),
                onLongPressEnd: () => onReelLongPressEnd(index),
              );
            },
          ),
        ),
        if (isLoadingMore)
          Positioned(
            left: 0,
            right: 0,
            bottom: 12 + bottomInset,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: context.colors.reelsForegroundMuted,
                  strokeWidth: 2.2,
                ),
              ),
            ),
          ),
        if (failureMessage != null)
          ReelsFailureBanner(
            message: failureMessage!,
            topOffset: topControlsOffset,
          ),
      ],
    );
  }
}
