import 'package:reels_assignment/core/bloc/base_cubit.dart';
import 'package:reels_assignment/core/constants/app_constants.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/core/usecases/usecase.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/domain/usecases/get_reels.dart';
import 'package:reels_assignment/features/reels/domain/usecases/seed_demo_reels.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_state.dart';

class ReelsCubit extends BaseCubit<ReelsState> {
  ReelsCubit({required this.getReels, required this.seedDemoReels})
    : super(const ReelsInitial());

  final GetReels getReels;
  final SeedDemoReels seedDemoReels;

  DateTime? _cursorCreatedAt;

  Future<void> loadReels({bool refresh = true}) async {
    if (refresh) {
      _cursorCreatedAt = null;
    }

    final previousReels = state.reels;
    final previousHasMore = state.hasMore;
    final previousSeeding = state.isSeeding;

    emit(
      ReelsLoading(
        reels: previousReels,
        hasMore: previousHasMore,
        isSeeding: previousSeeding,
      ),
    );

    final result = await getReels(
      GetReelsParams(
        pageSize: AppConstants.reelsPageSize,
        cursorCreatedAt: _cursorCreatedAt,
      ),
    );
    result.fold(
      (failure) => emit(
        ReelsFailure(
          failure: failure,
          reels: previousReels,
          hasMore: previousHasMore,
          isSeeding: previousSeeding,
        ),
      ),
      (reels) {
        _cursorCreatedAt = _extractCursor(reels);
        emit(
          ReelsLoaded(
            reels: reels,
            hasMore: reels.length == AppConstants.reelsPageSize,
            isSeeding: previousSeeding,
          ),
        );
      },
    );
  }

  Future<void> loadMoreIfNeeded(int activeIndex) async {
    final currentState = state;
    if (currentState is! ReelsLoaded) {
      return;
    }

    final isNearEnd =
        activeIndex >=
        (currentState.reels.length - AppConstants.reelsPaginationThreshold);
    if (!isNearEnd || currentState.isLoadingMore || !currentState.hasMore) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getReels(
      GetReelsParams(
        pageSize: AppConstants.reelsPageSize,
        cursorCreatedAt: _cursorCreatedAt,
      ),
    );
    result.fold(
      (failure) {
        emit(
          ReelsFailure(
            failure: failure,
            reels: currentState.reels,
            hasMore: currentState.hasMore,
            isLoadingMore: false,
            isSeeding: currentState.isSeeding,
          ),
        );
      },
      (fetchedReels) {
        final mergedReels = _mergeUniqueById(currentState.reels, fetchedReels);
        _cursorCreatedAt = _extractCursor(fetchedReels) ?? _cursorCreatedAt;

        emit(
          currentState.copyWith(
            reels: mergedReels,
            isLoadingMore: false,
            hasMore: fetchedReels.length == AppConstants.reelsPageSize,
          ),
        );
      },
    );
  }

  Future<String?> seedDemoData() async {
    if (state.isSeeding) {
      return 'Seeding already in progress.';
    }

    emit(_stateWithSeeding(isSeeding: true));
    final result = await seedDemoReels(const NoParams());

    String? errorMessage;
    await result.fold(
      (failure) async {
        errorMessage = failure.message;
        emit(_stateWithSeeding(isSeeding: false, failureOverride: failure));
      },
      (_) async {
        emit(_stateWithSeeding(isSeeding: false));
        await loadReels(refresh: true);
      },
    );

    return errorMessage;
  }

  Future<void> retry() async {
    await loadReels(refresh: true);
  }

  ReelsState _stateWithSeeding({
    required bool isSeeding,
    Failure? failureOverride,
  }) {
    return switch (state) {
      ReelsInitial() => ReelsInitial(isSeeding: isSeeding),
      ReelsLoading loadingState => ReelsLoading(
        reels: loadingState.reels,
        hasMore: loadingState.hasMore,
        isSeeding: isSeeding,
      ),
      ReelsLoaded loaded => loaded.copyWith(isSeeding: isSeeding),
      ReelsFailure failureState => failureState.copyWith(
        isSeeding: isSeeding,
        failure: failureOverride,
      ),
    };
  }

  DateTime? _extractCursor(List<Reel> reels) {
    for (var i = reels.length - 1; i >= 0; i--) {
      final reel = reels[i];
      if (reel.createdAt != null) {
        return reel.createdAt;
      }
    }
    return null;
  }

  List<Reel> _mergeUniqueById(List<Reel> existing, List<Reel> incoming) {
    final byId = <String, Reel>{for (final reel in existing) reel.id: reel};

    for (final reel in incoming) {
      byId[reel.id] = reel;
    }

    final merged = byId.values.toList();
    merged.sort((a, b) {
      final aTime = a.createdAt;
      final bTime = b.createdAt;
      if (aTime == null && bTime == null) {
        return 0;
      }
      if (aTime == null) {
        return 1;
      }
      if (bTime == null) {
        return -1;
      }
      return bTime.compareTo(aTime);
    });
    return merged;
  }
}
