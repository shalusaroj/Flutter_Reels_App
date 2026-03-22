import 'package:dartz/dartz.dart';
import 'package:reels_assignment/core/error/failures.dart';
import 'package:reels_assignment/core/usecases/usecase.dart';
import 'package:reels_assignment/features/reels/domain/repositories/reels_repository.dart';

class SeedDemoReels implements UseCase<Either<Failure, void>, NoParams> {
  const SeedDemoReels(this.repository);

  final ReelsRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.seedDemoReels();
  }
}
