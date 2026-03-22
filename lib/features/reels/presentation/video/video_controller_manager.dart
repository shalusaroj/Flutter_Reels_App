import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';

class VideoControllerManager {
  VideoPlayerController? _controller;
  int? _controllerIndex;
  String? _controllerUrl;
  int _requestToken = 0;

  VideoPlayerController? get controller => _controller;
  int? get controllerIndex => _controllerIndex;
  String? get controllerUrl => _controllerUrl;

  bool matches({required int index, required String url}) {
    return _controller != null &&
        _controllerIndex == index &&
        _controllerUrl == url &&
        _controller!.value.isInitialized;
  }

  Future<VideoPlayerController?> ensureController({
    required int index,
    required String url,
    required bool isMuted,
  }) async {
    final existing = _controller;
    if (existing != null &&
        _controllerIndex == index &&
        _controllerUrl == url &&
        existing.value.isInitialized) {
      await _safeSetVolume(existing, isMuted ? 0.0 : 1.0);
      return existing;
    }

    final requestToken = ++_requestToken;

    await _disposeCurrentControllerOnly();
    _controllerIndex = index;
    _controllerUrl = url;

    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      if (requestToken != _requestToken) {
        return null;
      }

      final nextController = VideoPlayerController.file(file);
      await nextController.setLooping(true);
      await nextController.initialize();
      await _safeSetVolume(nextController, isMuted ? 0.0 : 1.0);

      if (requestToken != _requestToken) {
        await _safeDispose(nextController);
        return null;
      }

      _controller = nextController;
      return nextController;
    } catch (_) {
      if (requestToken == _requestToken) {
        _controller = null;
      }
      return null;
    }
  }

  Future<void> prefetch(String url) async {
    try {
      await DefaultCacheManager().downloadFile(url, key: url, force: false);
    } catch (_) {
      // Ignore prefetch failures; playback should continue.
    }
  }

  Future<void> play() async {
    final current = _controller;
    if (current == null || !current.value.isInitialized) {
      return;
    }

    try {
      await current.play();
    } catch (_) {
      // Ignore race conditions when rapidly switching media.
    }
  }

  Future<void> pause() async {
    final current = _controller;
    if (current == null || !current.value.isInitialized) {
      return;
    }

    try {
      if (current.value.isPlaying) {
        await current.pause();
      }
    } catch (_) {
      // Ignore race conditions when rapidly switching media.
    }
  }

  Future<void> setMuted(bool isMuted) async {
    final current = _controller;
    if (current == null || !current.value.isInitialized) {
      return;
    }

    await _safeSetVolume(current, isMuted ? 0.0 : 1.0);
  }

  Future<void> disposeCurrent() async {
    _requestToken += 1;
    await _disposeCurrentControllerOnly();
    _controllerIndex = null;
    _controllerUrl = null;
  }

  Future<void> _disposeCurrentControllerOnly() async {
    final current = _controller;
    _controller = null;
    if (current != null) {
      await _safeDispose(current);
    }
  }

  Future<void> _safeSetVolume(
    VideoPlayerController controller,
    double volume,
  ) async {
    try {
      if (controller.value.isInitialized) {
        await controller.setVolume(volume);
      }
    } catch (_) {
      // Ignore stale controller volume updates.
    }
  }

  Future<void> _safeDispose(VideoPlayerController controller) async {
    try {
      await controller.dispose();
    } catch (_) {
      // Ignore disposal failures for stale controllers.
    }
  }
}
