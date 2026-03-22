import 'package:reels_assignment/core/data/data_request.dart';
import 'package:reels_assignment/core/data/data_source_type.dart';

abstract class AbstractDataClient {
  DataSourceType get sourceType;

  Future<Object?> execute(DataRequest request);

  Future<Map<String, dynamic>?> get(DataRequest request);

  Future<List<Map<String, dynamic>>> getList(DataRequest request);

  Future<void> create(DataRequest request);

  Future<void> post(DataRequest request);

  Future<void> put(DataRequest request);

  Future<void> patch(DataRequest request);

  Future<void> upsert(DataRequest request);

  Future<void> delete(DataRequest request);
}
