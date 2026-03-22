import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

class ReelsPlaybackState extends Equatable {
  const ReelsPlaybackState({
    this.activeIndex = 0,
    this.isMuted = false,
    this.controllers = const <int, VideoPlayerController>{},
    this.loadingIndexes = const <int>{},
    this.likeAnimationTokens = const <int, int>{},
    this.revision = 0,
  });

  final int activeIndex;
  final bool isMuted;
  final Map<int, VideoPlayerController> controllers;
  final Set<int> loadingIndexes;
  final Map<int, int> likeAnimationTokens;
  final int revision;

  ReelsPlaybackState copyWith({
    int? activeIndex,
    bool? isMuted,
    Map<int, VideoPlayerController>? controllers,
    Set<int>? loadingIndexes,
    Map<int, int>? likeAnimationTokens,
    int? revision,
  }) {
    return ReelsPlaybackState(
      activeIndex: activeIndex ?? this.activeIndex,
      isMuted: isMuted ?? this.isMuted,
      controllers: controllers ?? this.controllers,
      loadingIndexes: loadingIndexes ?? this.loadingIndexes,
      likeAnimationTokens: likeAnimationTokens ?? this.likeAnimationTokens,
      revision: revision ?? this.revision,
    );
  }

  @override
  List<Object?> get props => [
    activeIndex,
    isMuted,
    loadingIndexes,
    likeAnimationTokens,
    revision,
  ];
}
