import 'package:dartz/dartz.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';

abstract class ReelsRepository {
  Future<Either<Failure, List<Reel>>> getReels();
  Future<Either<Failure, List<Reel>>> getReelsPage({
    required int pageSize,
    DateTime? cursorCreatedAt,
  });
  Future<Either<Failure, int>> likeReel({
    required String reelId,
    required int delta,
  });
  Future<Either<Failure, void>> seedDemoReels();
}
