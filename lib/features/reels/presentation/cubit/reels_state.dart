import 'package:reels_assignment/core/bloc/base_state.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';

sealed class ReelsState extends BaseState {
  const ReelsState({
    this.reels = const <Reel>[],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isSeeding = false,
  });

  final List<Reel> reels;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isSeeding;

  @override
  List<Object?> get props => [
    runtimeType,
    reels,
    hasMore,
    isLoadingMore,
    isSeeding,
  ];
}

final class ReelsInitial extends ReelsState {
  const ReelsInitial({super.isSeeding});
}

final class ReelsLoading extends ReelsState {
  const ReelsLoading({super.reels, super.hasMore, super.isSeeding});
}

final class ReelsLoaded extends ReelsState {
  const ReelsLoaded({
    required super.reels,
    required super.hasMore,
    super.isLoadingMore,
    super.isSeeding,
  });

  ReelsLoaded copyWith({
    List<Reel>? reels,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSeeding,
  }) {
    return ReelsLoaded(
      reels: reels ?? this.reels,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSeeding: isSeeding ?? this.isSeeding,
    );
  }
}

final class ReelsFailure extends ReelsState {
  const ReelsFailure({
    required this.failure,
    super.reels,
    super.hasMore,
    super.isLoadingMore,
    super.isSeeding,
  });

  final Failure failure;

  ReelsFailure copyWith({
    Failure? failure,
    List<Reel>? reels,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSeeding,
  }) {
    return ReelsFailure(
      failure: failure ?? this.failure,
      reels: reels ?? this.reels,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSeeding: isSeeding ?? this.isSeeding,
    );
  }

  @override
  List<Object?> get props => [...super.props, failure];
}
