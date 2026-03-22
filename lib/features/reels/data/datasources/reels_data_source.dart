import 'package:reels_assignment/features/reels/data/models/reel_model.dart';

abstract class ReelsDataSource {
  Future<List<ReelModel>> getReelsPage({
    required int pageSize,
    DateTime? cursorCreatedAt,
  });
}

abstract class ReelsRemoteDataSource extends ReelsDataSource {
  Future<void> seedDemoReels();
  Future<int> adjustLike({required String reelId, required int delta});
}

abstract class ReelsLocalDataSource extends ReelsDataSource {
  Future<void> saveReels(List<ReelModel> reels, {bool reset = false});
  Future<void> updateReelLikes({required String reelId, required int likes});
}
