import 'dart:math' as math;

import 'package:reels_assignment/core/bloc/base_cubit.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/domain/usecases/like_reel.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reel_likes_state.dart';

class ReelLikesCubit extends BaseCubit<ReelLikesState> {
  ReelLikesCubit({required this.likeReel}) : super(const ReelLikesState());

  final LikeReel likeReel;

  void syncReels(List<Reel> reels) {
    if (reels.isEmpty && state.likeCounts.isEmpty) {
      return;
    }

    final reelIds = reels.map((reel) => reel.id).toSet();
    final nextLikeCounts = <String, int>{};
    final nextLikedReelIds = <String>{};
    final nextSyncingReelIds = <String>{};
    final nextFailuresByReelId = <String, Failure>{};

    for (final reel in reels) {
      final hasLocalInteraction =
          state.likedReelIds.contains(reel.id) ||
          state.syncingReelIds.contains(reel.id);

      nextLikeCounts[reel.id] =
          hasLocalInteraction
              ? (state.likeCounts[reel.id] ?? reel.likes)
              : reel.likes;

      if (state.likedReelIds.contains(reel.id)) {
        nextLikedReelIds.add(reel.id);
      }
      if (state.syncingReelIds.contains(reel.id)) {
        nextSyncingReelIds.add(reel.id);
      }
      final failure = state.failuresByReelId[reel.id];
      if (failure != null) {
        nextFailuresByReelId[reel.id] = failure;
      }
    }

    nextLikedReelIds.removeWhere((id) => !reelIds.contains(id));
    nextSyncingReelIds.removeWhere((id) => !reelIds.contains(id));
    nextFailuresByReelId.removeWhere((id, _) => !reelIds.contains(id));

    emit(
      state.copyWith(
        likeCounts: nextLikeCounts,
        likedReelIds: nextLikedReelIds,
        syncingReelIds: nextSyncingReelIds,
        failuresByReelId: nextFailuresByReelId,
      ),
    );
  }

  Future<void> toggleLike(Reel reel) async {
    final shouldLike = !state.isLiked(reel.id);
    await _setLikeStatus(reel: reel, shouldLike: shouldLike);
  }

  Future<void> ensureLiked(Reel reel) async {
    if (state.isLiked(reel.id)) {
      return;
    }
    await _setLikeStatus(reel: reel, shouldLike: true);
  }

  Future<void> _setLikeStatus({
    required Reel reel,
    required bool shouldLike,
  }) async {
    final reelId = reel.id;
    if (state.isSyncing(reelId)) {
      return;
    }

    final previousLiked = state.isLiked(reelId);
    if (previousLiked == shouldLike) {
      return;
    }

    final previousLikes = state.likesFor(
      reelId: reelId,
      fallbackLikes: reel.likes,
    );
    final delta = shouldLike ? 1 : -1;
    final optimisticLikes = math.max(0, previousLikes + delta);

    final optimisticLikeCounts = Map<String, int>.from(state.likeCounts)
      ..[reelId] = optimisticLikes;
    final optimisticLikedReelIds = Set<String>.from(state.likedReelIds);
    if (shouldLike) {
      optimisticLikedReelIds.add(reelId);
    } else {
      optimisticLikedReelIds.remove(reelId);
    }
    final optimisticSyncingReelIds = Set<String>.from(state.syncingReelIds)
      ..add(reelId);
    final optimisticFailuresByReelId = Map<String, Failure>.from(
      state.failuresByReelId,
    )..remove(reelId);

    emit(
      state.copyWith(
        likeCounts: optimisticLikeCounts,
        likedReelIds: optimisticLikedReelIds,
        syncingReelIds: optimisticSyncingReelIds,
        failuresByReelId: optimisticFailuresByReelId,
      ),
    );

    final result = await likeReel(LikeReelParams(reelId: reelId, delta: delta));

    result.fold(
      (failure) {
        final rollbackLikeCounts = Map<String, int>.from(state.likeCounts)
          ..[reelId] = previousLikes;
        final rollbackLikedReelIds = Set<String>.from(state.likedReelIds);
        if (previousLiked) {
          rollbackLikedReelIds.add(reelId);
        } else {
          rollbackLikedReelIds.remove(reelId);
        }
        final rollbackSyncingReelIds = Set<String>.from(state.syncingReelIds)
          ..remove(reelId);
        final rollbackFailuresByReelId = Map<String, Failure>.from(
          state.failuresByReelId,
        )..[reelId] = failure;

        emit(
          state.copyWith(
            likeCounts: rollbackLikeCounts,
            likedReelIds: rollbackLikedReelIds,
            syncingReelIds: rollbackSyncingReelIds,
            failuresByReelId: rollbackFailuresByReelId,
          ),
        );
      },
      (syncedLikes) {
        final syncedLikeCounts = Map<String, int>.from(state.likeCounts)
          ..[reelId] = syncedLikes;
        final syncedLikedReelIds = Set<String>.from(state.likedReelIds);
        if (shouldLike) {
          syncedLikedReelIds.add(reelId);
        } else {
          syncedLikedReelIds.remove(reelId);
        }
        final syncedSyncingReelIds = Set<String>.from(state.syncingReelIds)
          ..remove(reelId);
        final syncedFailuresByReelId = Map<String, Failure>.from(
          state.failuresByReelId,
        )..remove(reelId);

        emit(
          state.copyWith(
            likeCounts: syncedLikeCounts,
            likedReelIds: syncedLikedReelIds,
            syncingReelIds: syncedSyncingReelIds,
            failuresByReelId: syncedFailuresByReelId,
          ),
        );
      },
    );
  }
}
