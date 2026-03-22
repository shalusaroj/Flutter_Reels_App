class AppConstants {
  const AppConstants._();

  static const String baseApiUrl = 'https://example.com';
  static const String databaseName = 'reels_assignment.db';
  static const String coreCacheTable = 'core_cache';

  // Firestore
  static const String reelsCollection = 'reels';
  static const String reelsLocalTable = 'reels_local';
  static const int reelsFetchLimit = 50;
  static const int reelsPageSize = 6;
  static const int reelsPaginationThreshold = 2;

  // Playback
  static const int reelsPreloadCount = 4;
}
