import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:path/path.dart' as p;
import 'package:reels_assignment/core/constants/app_constants.dart';
import 'package:reels_assignment/core/data/api_data_client.dart';
import 'package:reels_assignment/core/data/firebase_data_client.dart';
import 'package:reels_assignment/core/data/sqlite_data_client.dart';
import 'package:reels_assignment/core/network/dio_factory.dart';
import 'package:reels_assignment/core/network/network_info.dart';
import 'package:reels_assignment/features/reels/data/datasources/reels_data_source.dart';
import 'package:reels_assignment/features/reels/data/datasources/reels_local_data_source.dart';
import 'package:reels_assignment/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:reels_assignment/features/reels/data/repositories/reels_repository_impl.dart';
import 'package:reels_assignment/features/reels/domain/repositories/reels_repository.dart';
import 'package:reels_assignment/features/reels/domain/usecases/get_reels.dart';
import 'package:reels_assignment/features/reels/domain/usecases/like_reel.dart';
import 'package:reels_assignment/features/reels/domain/usecases/seed_demo_reels.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reel_likes_cubit.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_cubit.dart';
import 'package:reels_assignment/features/reels/presentation/cubit/reels_playback_cubit.dart';
import 'package:reels_assignment/presentation/route/app_router.dart';
import 'package:sqflite/sqflite.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Makes init safe to call multiple times (tests, future module bootstrap, etc.)
  if (getIt.isRegistered<ReelsRepository>()) {
    return;
  }

  // External
  getIt.registerLazySingleton(() => InternetConnectionChecker.instance);
  getIt.registerLazySingleton<Dio>(() => DioFactory.create());
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  final database = await openDatabase(
    p.join(await getDatabasesPath(), AppConstants.databaseName),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.coreCacheTable}(
          id TEXT PRIMARY KEY,
          cacheKey TEXT UNIQUE NOT NULL,
          cacheValue TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.reelsLocalTable}(
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL,
          caption TEXT NOT NULL,
          videoUrl TEXT NOT NULL,
          likes INTEGER NOT NULL DEFAULT 0,
          isActive INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT
        )
      ''');
    },
    onOpen: (db) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${AppConstants.reelsLocalTable}(
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL,
          caption TEXT NOT NULL,
          videoUrl TEXT NOT NULL,
          likes INTEGER NOT NULL DEFAULT 0,
          isActive INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT
        )
      ''');
    },
  );
  getIt.registerLazySingleton<Database>(() => database);

  // Core network
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(getIt()));

  // Client implementations
  getIt.registerLazySingleton(() => FirebaseDataClient(firestore: getIt()));
  getIt.registerLazySingleton(
    () => ApiDataClient(dio: getIt(), baseUrl: AppConstants.baseApiUrl),
  );
  getIt.registerLazySingleton(() => SqliteDataClient(database: getIt()));

  // Reels feature
  getIt.registerFactory(
    () => ReelsCubit(getReels: getIt(), seedDemoReels: getIt()),
  );
  getIt.registerFactory(() => ReelLikesCubit(likeReel: getIt()));
  getIt.registerFactory(() => ReelsPlaybackCubit());

  getIt.registerLazySingleton(() => GetReels(getIt()));
  getIt.registerLazySingleton(() => LikeReel(getIt()));
  getIt.registerLazySingleton(() => SeedDemoReels(getIt()));

  getIt.registerLazySingleton<ReelsRepository>(
    () => ReelsRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      networkInfo: getIt(),
    ),
  );

  getIt.registerLazySingleton<ReelsRemoteDataSource>(
    () => ReelsRemoteDataSourceImpl(client: getIt<FirebaseDataClient>()),
  );
  getIt.registerLazySingleton<ReelsLocalDataSource>(
    () => ReelsLocalDataSourceImpl(client: getIt<SqliteDataClient>()),
  );

  // Presentation
  getIt.registerLazySingleton(() => AppRouter());
}
