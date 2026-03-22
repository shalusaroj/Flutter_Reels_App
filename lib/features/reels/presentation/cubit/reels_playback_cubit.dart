import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_playback_state.dart';
import 'package:reels_assignment/features/reels/presentation/video/video_controller_manager.dart';
import 'package:video_player/video_player.dart';

class ReelsPlaybackCubit extends Cubit<ReelsPlaybackState> {
  ReelsPlaybackCubit() : super(const ReelsPlaybackState());

  final VideoControllerManager _videoManager = VideoControllerManager();
  final Map<int, int> _likeAnimationTokens = {};
  final Map<int, Timer> _likeAnimationTimers = {};
  final Set<int> _holdPausedIndexes = <int>{};
  final Set<String> _prefetchingUrls = <String>{};

  List<Reel> _latestReels = const [];
  int _activeIndex = 0;
  bool _isMuted = false;
  bool _isUserPaused = false;
  bool _isPlaybackBootstrapScheduled = false;
  int _likeAnimationSequence = 0;
  int? _loadingIndex;
  int _controllerLoadSequence = 0;

  Future<void> syncFeed(List<Reel> reels) async {
    _latestReels = reels;

    if (reels.isEmpty) {
      _activeIndex = 0;
      _isUserPaused = false;
      _loadingIndex = null;
      _holdPausedIndexes.clear();
      await _disposeAllControllers();
      _clearAllLikeAnimations();
      _publish();
      return;
    }

    if (_activeIndex >= reels.length) {
      _activeIndex = 0;
      _isUserPaused = false;
    }

    await _disposeControllerIfNoLongerMatchingFeed(reels);
    _trimStaleInteractionState(reels);
    _publish();
    _schedulePlaybackIfNeeded();
    _prefetchNextVideo();
  }

  void handleLifecycle(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _holdPausedIndexes.clear();
      unawaited(_resumeActiveController());
      return;
    }

    if (lifecycleState == AppLifecycleState.inactive ||
        lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.detached) {
      _holdPausedIndexes.clear();
      unawaited(_pauseActiveController());
    }
  }

  Future<void> onPageChanged(int index) async {
    if (index < 0 || index >= _latestReels.length) {
      return;
    }

    if (index != _activeIndex) {
      _isUserPaused = false;
    }

    _activeIndex = index;
    _holdPausedIndexes.removeWhere((value) => value != _activeIndex);
    _publish();

    // Let the frame complete so off-screen pages can rebuild without the old
    // controller before we swap/dispose players.
    await SchedulerBinding.instance.endOfFrame;
    if (isClosed || _activeIndex != index) {
      return;
    }

    await _ensureActiveController(playWhenReady: true);
    _prefetchNextVideo();
  }

  Future<void> onScrollStart() async {
    // Intentionally no-op:
    // dragging should preserve current running/paused state.
  }

  Future<void> onScrollEnd() async {
    await _ensureActiveController(playWhenReady: true);
  }

  Future<void> onReelTap(int index) async {
    if (index != _activeIndex) {
      return;
    }

    final controller = await _ensureActiveController(playWhenReady: false);
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      _isUserPaused = true;
      await _videoManager.pause();
    } else {
      _isUserPaused = false;
      await _videoManager.play();
    }
    _publish();
  }

  Future<void> onReelLongPressStart(int index) async {
    if (index != _activeIndex) {
      return;
    }

    final controller = _videoManager.controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (!controller.value.isPlaying) {
      return;
    }

    _holdPausedIndexes.add(index);
    await _videoManager.pause();
  }

  Future<void> onReelLongPressEnd(int index) async {
    if (!_holdPausedIndexes.remove(index)) {
      return;
    }
    if (index != _activeIndex) {
      return;
    }
    if (_isUserPaused) {
      return;
    }

    await _videoManager.play();
  }

  void triggerLikeAnimation(int index) {
    _likeAnimationTimers[index]?.cancel();

    _likeAnimationSequence += 1;
    _likeAnimationTokens[index] = _likeAnimationSequence;
    _publish();

    _likeAnimationTimers[index] = Timer(const Duration(milliseconds: 700), () {
      _likeAnimationTokens.remove(index);
      _likeAnimationTimers.remove(index);
      _publish();
    });
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _videoManager.setMuted(_isMuted);
    _publish();
  }

  Future<void> _ensureInitialPlayback() async {
    if (_latestReels.isEmpty) {
      return;
    }

    if (_activeIndex >= _latestReels.length) {
      _activeIndex = 0;
      _isUserPaused = false;
      _publish();
    }

    await _ensureActiveController(playWhenReady: true);
    _prefetchNextVideo();
  }

  void _schedulePlaybackIfNeeded() {
    if (_latestReels.isEmpty || _isPlaybackBootstrapScheduled) {
      return;
    }

    _isPlaybackBootstrapScheduled = true;
    Future<void>(() async {
      _isPlaybackBootstrapScheduled = false;
      if (isClosed) {
        return;
      }
      await _ensureInitialPlayback();
    });
  }

  Future<VideoPlayerController?> _ensureActiveController({
    required bool playWhenReady,
  }) async {
    if (_latestReels.isEmpty ||
        _activeIndex < 0 ||
        _activeIndex >= _latestReels.length) {
      return null;
    }

    final activeReel = _latestReels[_activeIndex];
    final shouldPlay =
        playWhenReady &&
        !_isUserPaused &&
        !_holdPausedIndexes.contains(_activeIndex);

    if (_videoManager.matches(index: _activeIndex, url: activeReel.videoUrl)) {
      await _videoManager.setMuted(_isMuted);
      final existing = _videoManager.controller;
      if (existing != null && shouldPlay && !existing.value.isPlaying) {
        await _videoManager.play();
      }
      return existing;
    }

    final loadSequence = ++_controllerLoadSequence;
    _loadingIndex = _activeIndex;
    _publish();

    final controller = await _videoManager.ensureController(
      index: _activeIndex,
      url: activeReel.videoUrl,
      isMuted: _isMuted,
    );

    if (isClosed || loadSequence != _controllerLoadSequence) {
      return controller;
    }

    _loadingIndex = null;

    if (controller != null && shouldPlay) {
      await _videoManager.play();
    }

    _publish();
    return controller;
  }

  Future<void> _disposeControllerIfNoLongerMatchingFeed(
    List<Reel> reels,
  ) async {
    final controller = _videoManager.controller;
    final controllerIndex = _videoManager.controllerIndex;
    final controllerUrl = _videoManager.controllerUrl;

    if (controller == null ||
        controllerIndex == null ||
        controllerUrl == null) {
      return;
    }

    final isIndexValid = controllerIndex >= 0 && controllerIndex < reels.length;
    if (!isIndexValid || reels[controllerIndex].videoUrl != controllerUrl) {
      await _videoManager.disposeCurrent();
      if (_loadingIndex == controllerIndex) {
        _loadingIndex = null;
      }
    }
  }

  void _prefetchNextVideo() {
    final nextIndex = _activeIndex + 1;
    if (nextIndex < 0 || nextIndex >= _latestReels.length) {
      return;
    }

    final nextUrl = _latestReels[nextIndex].videoUrl;
    if (nextUrl.isEmpty || !_prefetchingUrls.add(nextUrl)) {
      return;
    }

    unawaited(
      _videoManager.prefetch(nextUrl).whenComplete(() {
        _prefetchingUrls.remove(nextUrl);
      }),
    );
  }

  void _trimStaleInteractionState(List<Reel> reels) {
    _holdPausedIndexes.removeWhere((index) => index >= reels.length);

    final staleAnimationIndexes =
        _likeAnimationTokens.keys
            .where((index) => index >= reels.length)
            .toList();
    for (final index in staleAnimationIndexes) {
      _clearLikeAnimation(index);
    }
  }

  Future<void> _pauseActiveController() async {
    await _videoManager.pause();
  }

  Future<void> _resumeActiveController() async {
    if (_latestReels.isEmpty) {
      return;
    }
    if (_activeIndex >= _latestReels.length) {
      _activeIndex = 0;
      _isUserPaused = false;
      _publish();
    }

    await _ensureActiveController(playWhenReady: true);
  }

  void _publish() {
    if (isClosed) {
      return;
    }

    final currentController = _videoManager.controller;
    final currentControllerIndex = _videoManager.controllerIndex;

    final controllers = <int, VideoPlayerController>{
      if (currentController != null &&
          currentControllerIndex != null &&
          currentControllerIndex == _activeIndex)
        currentControllerIndex: currentController,
    };

    final loadingIndexes = <int>{if (_loadingIndex != null) _loadingIndex!};

    final didStateChange =
        state.activeIndex != _activeIndex ||
        state.isMuted != _isMuted ||
        !_sameControllerMap(state.controllers, controllers) ||
        !_sameIntSet(state.loadingIndexes, loadingIndexes) ||
        !_sameIntMap(state.likeAnimationTokens, _likeAnimationTokens);
    if (!didStateChange) {
      return;
    }

    emit(
      ReelsPlaybackState(
        activeIndex: _activeIndex,
        isMuted: _isMuted,
        controllers: Map<int, VideoPlayerController>.unmodifiable(controllers),
        loadingIndexes: Set<int>.unmodifiable(loadingIndexes),
        likeAnimationTokens: Map<int, int>.unmodifiable(_likeAnimationTokens),
        revision: state.revision + 1,
      ),
    );
  }

  bool _sameControllerMap(
    Map<int, VideoPlayerController> left,
    Map<int, VideoPlayerController> right,
  ) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!identical(right[entry.key], entry.value)) {
        return false;
      }
    }
    return true;
  }

  bool _sameIntSet(Set<int> left, Set<int> right) {
    if (left.length != right.length) {
      return false;
    }
    for (final value in left) {
      if (!right.contains(value)) {
        return false;
      }
    }
    return true;
  }

  bool _sameIntMap(Map<int, int> left, Map<int, int> right) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (right[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }

  Future<void> _disposeAllControllers() async {
    await _videoManager.disposeCurrent();
  }

  void _clearLikeAnimation(int index) {
    _likeAnimationTimers[index]?.cancel();
    _likeAnimationTimers.remove(index);
    _likeAnimationTokens.remove(index);
  }

  void _clearAllLikeAnimations() {
    for (final timer in _likeAnimationTimers.values) {
      timer.cancel();
    }
    _likeAnimationTimers.clear();
    _likeAnimationTokens.clear();
  }

  @override
  Future<void> close() async {
    _clearAllLikeAnimations();
    await _disposeAllControllers();
    _holdPausedIndexes.clear();
    _prefetchingUrls.clear();
    return super.close();
  }
}
