import 'package:reels_assignment/core/data/abstract_data_client.dart';
import 'package:reels_assignment/core/data/data_operation.dart';
import 'package:reels_assignment/core/data/data_request.dart';
import 'package:reels_assignment/core/data/data_source_type.dart';
import 'package:reels_assignment/core/error/exceptions.dart';
import 'package:sqflite/sqflite.dart';

class SqliteDataClient extends AbstractDataClient {
  SqliteDataClient({required this.database});

  final Database database;

  @override
  DataSourceType get sourceType => DataSourceType.local;

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
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for SQLite get.');
    }

    try {
      final rows = await database.query(
        request.path,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) {
        return null;
      }
      return Map<String, dynamic>.from(rows.first);
    } catch (error) {
      throw CacheException('SQLite get failed: $error');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(DataRequest request) async {
    try {
      final rows = await database.query(
        request.path,
        where: _whereClause(request.filters),
        whereArgs: _whereArgs(request.filters),
        orderBy: _orderBy(request),
        limit: request.limit,
      );
      return rows.map((row) => Map<String, dynamic>.from(row)).toList();
    } catch (error) {
      throw CacheException('SQLite getList failed: $error');
    }
  }

  @override
  Future<void> create(DataRequest request) async {
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for SQLite create.');
    }

    try {
      await database.insert(
        request.path,
        payload,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    } catch (error) {
      throw CacheException('SQLite create failed: $error');
    }
  }

  @override
  Future<void> post(DataRequest request) async {
    await create(request);
  }

  @override
  Future<void> put(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for SQLite put.');
    }
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for SQLite put.');
    }

    try {
      final data = <String, dynamic>{...payload, 'id': id};
      final updatedRows = await database.update(
        request.path,
        data,
        where: 'id = ?',
        whereArgs: [id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (updatedRows == 0) {
        await database.insert(
          request.path,
          data,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (error) {
      throw CacheException('SQLite put failed: $error');
    }
  }

  @override
  Future<void> patch(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for SQLite patch.');
    }
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for SQLite patch.');
    }

    try {
      await database.update(
        request.path,
        payload,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (error) {
      throw CacheException('SQLite patch failed: $error');
    }
  }

  @override
  Future<void> upsert(DataRequest request) async {
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for SQLite upsert.');
    }

    try {
      await database.insert(
        request.path,
        payload,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (error) {
      throw CacheException('SQLite upsert failed: $error');
    }
  }

  @override
  Future<void> delete(DataRequest request) async {
    try {
      if (request.id != null) {
        await database.delete(
          request.path,
          where: 'id = ?',
          whereArgs: [request.id],
        );
        return;
      }

      await database.delete(
        request.path,
        where: _whereClause(request.filters),
        whereArgs: _whereArgs(request.filters),
      );
    } catch (error) {
      throw CacheException('SQLite delete failed: $error');
    }
  }

  String? _whereClause(Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      return null;
    }
    return filters.keys.map((key) => '$key = ?').join(' AND ');
  }

  List<Object?>? _whereArgs(Map<String, dynamic>? filters) {
    if (filters == null || filters.isEmpty) {
      return null;
    }
    return filters.values.toList();
  }

  String? _orderBy(DataRequest request) {
    if (request.orderBy == null) {
      return null;
    }
    return '${request.orderBy} ${request.descending ? 'DESC' : 'ASC'}';
  }
}
