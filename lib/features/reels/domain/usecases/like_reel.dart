import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/core/usecases/usecase.dart';
import 'package:reels_assignment/features/reels/domain/repositories/reels_repository.dart';

class LikeReel implements UseCase<Either<Failure, int>, LikeReelParams> {
  const LikeReel(this.repository);

  final ReelsRepository repository;

  @override
  Future<Either<Failure, int>> call(LikeReelParams params) {
    return repository.likeReel(reelId: params.reelId, delta: params.delta);
  }
}

class LikeReelParams extends Equatable {
  const LikeReelParams({required this.reelId, required this.delta});

  final String reelId;
  final int delta;

  @override
  List<Object?> get props => [reelId, delta];
}
