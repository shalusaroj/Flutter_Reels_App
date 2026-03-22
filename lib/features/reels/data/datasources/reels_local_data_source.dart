import 'package:reels_assignment/core/constants/app_constants.dart';
import 'package:reels_assignment/core/data/base_data_source.dart';
import 'package:reels_assignment/core/data/data_request.dart';
import 'package:reels_assignment/core/data/sqlite_data_client.dart';
import 'package:reels_assignment/features/reels/data/datasources/reels_data_source.dart';
import 'package:reels_assignment/features/reels/data/models/reel_model.dart';

class ReelsLocalDataSourceImpl extends BaseDataSource<SqliteDataClient>
    implements ReelsLocalDataSource {
  const ReelsLocalDataSourceImpl({required SqliteDataClient client})
    : super(client);

  @override
  Future<List<ReelModel>> getReelsPage({
    required int pageSize,
    DateTime? cursorCreatedAt,
  }) async {
    final queryLimit = AppConstants.reelsFetchLimit;

    final rows = await client.getList(
      DataRequest(
        path: AppConstants.reelsLocalTable,
        limit: queryLimit,
        orderBy: 'createdAt',
        descending: true,
      ),
    );

    final allReels =
        rows
            .map(ReelModel.fromMap)
            .where((reel) => reel.videoUrl.isNotEmpty)
            .where((reel) => reel.isActive)
            .toList();

    final filtered =
        cursorCreatedAt == null
            ? allReels
            : allReels
                .where(
                  (reel) =>
                      reel.createdAt != null &&
                      reel.createdAt!.isBefore(cursorCreatedAt),
                )
                .toList();

    return filtered.take(pageSize).toList();
  }

  @override
  Future<void> saveReels(List<ReelModel> reels, {bool reset = false}) async {
    if (reset) {
      await client.delete(
        const DataRequest(path: AppConstants.reelsLocalTable),
      );
    }

    for (final reel in reels) {
      await client.upsert(
        DataRequest(
          path: AppConstants.reelsLocalTable,
          payload: reel.toLocalMap(),
        ),
      );
    }
  }

  @override
  Future<void> updateReelLikes({required String reelId, required int likes}) {
    return client.patch(
      DataRequest(
        path: AppConstants.reelsLocalTable,
        id: reelId,
        payload: {'likes': likes},
      ),
    );
  }
}
