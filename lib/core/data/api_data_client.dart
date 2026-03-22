import 'package:dio/dio.dart';
import 'package:reels_assignment/core/data/abstract_data_client.dart';
import 'package:reels_assignment/core/data/data_operation.dart';
import 'package:reels_assignment/core/data/data_request.dart';
import 'package:reels_assignment/core/data/data_source_type.dart';
import 'package:reels_assignment/core/error/exceptions.dart';

class ApiDataClient extends AbstractDataClient {
  ApiDataClient({required this.dio, required this.baseUrl});

  final Dio dio;
  final String baseUrl;

  @override
  DataSourceType get sourceType => DataSourceType.api;

  @override
  Future<Object?> execute(DataRequest request) async {
    switch (request.operation) {
      case DataOperation.get:
        return get(request);
      case DataOperation.getList:
        return getList(request);
      case DataOperation.create:
        await create(request);
        return null;
      case DataOperation.post:
        await post(request);
        return null;
      case DataOperation.put:
        await put(request);
        return null;
      case DataOperation.patch:
        await patch(request);
        return null;
      case DataOperation.upsert:
        await upsert(request);
        return null;
      case DataOperation.delete:
        await delete(request);
        return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> get(DataRequest request) async {
    try {
      final url = _resourceUrl(request.path, request.id);
      final response = await dio.get<dynamic>(
        url,
        queryParameters: request.filters,
      );

      final data = response.data;
      if (data == null) {
        return null;
      }
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }

      throw const DataClientException('Unexpected API object response format.');
    } on DioException catch (error) {
      throw ServerException('API get failed: ${error.message}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(DataRequest request) async {
    try {
      final response = await dio.get<dynamic>(
        _resourceUrl(request.path),
        queryParameters: request.filters,
      );

      final data = response.data;
      if (data == null) {
        return const [];
      }
      if (data is List) {
        return data
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        return [data];
      }
      if (data is Map) {
        return [Map<String, dynamic>.from(data)];
      }

      throw const DataClientException('Unexpected API list response format.');
    } on DioException catch (error) {
      throw ServerException('API getList failed: ${error.message}');
    }
  }

  @override
  Future<void> create(DataRequest request) async {
    await post(request);
  }

  @override
  Future<void> post(DataRequest request) async {
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for API post.');
    }

    try {
      await dio.post<dynamic>(_resourceUrl(request.path), data: payload);
    } on DioException catch (error) {
      throw ServerException('API post failed: ${error.message}');
    }
  }

  @override
  Future<void> put(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for API put.');
    }
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for API put.');
    }

    try {
      await dio.put<dynamic>(_resourceUrl(request.path, id), data: payload);
    } on DioException catch (error) {
      throw ServerException('API put failed: ${error.message}');
    }
  }

  @override
  Future<void> patch(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for API patch.');
    }
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for API patch.');
    }

    try {
      await dio.patch<dynamic>(_resourceUrl(request.path, id), data: payload);
    } on DioException catch (error) {
      throw ServerException('API patch failed: ${error.message}');
    }
  }

  @override
  Future<void> upsert(DataRequest request) async {
    if (request.id == null) {
      await post(request);
      return;
    }
    await put(request);
  }

  @override
  Future<void> delete(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for API delete.');
    }

    try {
      await dio.delete<dynamic>(_resourceUrl(request.path, id));
    } on DioException catch (error) {
      throw ServerException('API delete failed: ${error.message}');
    }
  }

  String _resourceUrl(String path, [String? id]) {
    if (id == null || id.isEmpty) {
      return '$baseUrl/$path';
    }
    return '$baseUrl/$path/$id';
  }
}
