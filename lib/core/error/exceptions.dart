class ServerException implements Exception {
  const ServerException(this.message);

  final String message;
}

class CacheException implements Exception {
  const CacheException(this.message);

  final String message;
}

class DataClientException implements Exception {
  const DataClientException(this.message);

  final String message;
}
