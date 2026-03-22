import 'package:dartz/dartz.dart';
import 'package:reels_assignment/core/constants/app_constants.dart';
import 'package:reels_assignment/core/error/exceptions.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/core/network/network_info.dart';
import 'package:reels_assignment/features/reels/data/datasources/reels_data_source.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/domain/repositories/reels_repository.dart';

class ReelsRepositoryImpl implements ReelsRepository {
  const ReelsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  final ReelsRemoteDataSource remoteDataSource;
  final ReelsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<Failure, List<Reel>>> getReels() async {
    return getReelsPage(pageSize: AppConstants.reelsPageSize);
  }

  @override
  Future<Either<Failure, List<Reel>>> getReelsPage({
    required int pageSize,
    DateTime? cursorCreatedAt,
  }) async {
    final connected = await networkInfo.isConnected;
    if (connected) {
      try {
        final reels = await remoteDataSource.getReelsPage(
          pageSize: pageSize,
          cursorCreatedAt: cursorCreatedAt,
        );
        try {
          await localDataSource.saveReels(
            reels,
            reset: cursorCreatedAt == null,
          );
        } on CacheException {
          // Feed should continue even if cache update fails.
        }
        return Right(reels);
      } on ServerException catch (error) {
        return _fallbackToLocalOrFailure(
          pageSize: pageSize,
          cursorCreatedAt: cursorCreatedAt,
          fallbackFailure: ServerFailure(error.message),
        );
      } on DataClientException catch (error) {
        return _fallbackToLocalOrFailure(
          pageSize: pageSize,
          cursorCreatedAt: cursorCreatedAt,
          fallbackFailure: ServerFailure(error.message),
        );
      } catch (_) {
        return _fallbackToLocalOrFailure(
          pageSize: pageSize,
          cursorCreatedAt: cursorCreatedAt,
          fallbackFailure: const ServerFailure(
            'Unable to fetch reels right now.',
          ),
        );
      }
    }

    return _fallbackToLocalOrFailure(
      pageSize: pageSize,
      cursorCreatedAt: cursorCreatedAt,
      fallbackFailure: const NetworkFailure(
        'No internet connection and no local reels available.',
      ),
    );
  }

  @override
  Future<Either<Failure, void>> seedDemoReels() async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const Left(NetworkFailure('No internet connection.'));
    }

    try {
      await remoteDataSource.seedDemoReels();
      return const Right(null);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on DataClientException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Unable to seed demo reels right now.'));
    }
  }

  @override
  Future<Either<Failure, int>> likeReel({
    required String reelId,
    required int delta,
  }) async {
    final connected = await networkInfo.isConnected;
    if (!connected) {
      return const Left(
        NetworkFailure('No internet connection for like sync.'),
      );
    }

    try {
      final likes = await remoteDataSource.adjustLike(
        reelId: reelId,
        delta: delta,
      );
      try {
        await localDataSource.updateReelLikes(reelId: reelId, likes: likes);
      } on CacheException {
        // Keep UI responsive even if local cache update fails.
      }
      return Right(likes);
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    } on DataClientException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Unable to update likes right now.'));
    }
  }

  Future<Either<Failure, List<Reel>>> _fallbackToLocalOrFailure({
    required int pageSize,
    DateTime? cursorCreatedAt,
    required Failure fallbackFailure,
  }) async {
    try {
      final localReels = await localDataSource.getReelsPage(
        pageSize: pageSize,
        cursorCreatedAt: cursorCreatedAt,
      );
      if (localReels.isNotEmpty) {
        return Right(localReels);
      }
      return Left(fallbackFailure);
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    } on DataClientException catch (error) {
      return Left(CacheFailure(error.message));
    } catch (_) {
      return Left(fallbackFailure);
    }
  }
}
