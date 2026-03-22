import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/core/usecases/usecase.dart';
import 'package:reels_assignment/features/reels/domain/entities/reel.dart';
import 'package:reels_assignment/features/reels/domain/repositories/reels_repository.dart';

class GetReels implements UseCase<Either<Failure, List<Reel>>, GetReelsParams> {
  const GetReels(this.repository);

  final ReelsRepository repository;

  @override
  Future<Either<Failure, List<Reel>>> call(GetReelsParams params) {
    return repository.getReelsPage(
      pageSize: params.pageSize,
      cursorCreatedAt: params.cursorCreatedAt,
    );
  }
}

class GetReelsParams extends Equatable {
  const GetReelsParams({required this.pageSize, this.cursorCreatedAt});

  final int pageSize;
  final DateTime? cursorCreatedAt;

  @override
  List<Object?> get props => [pageSize, cursorCreatedAt];
}
