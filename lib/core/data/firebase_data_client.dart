import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reels_assignment/core/data/abstract_data_client.dart';
import 'package:reels_assignment/core/data/data_operation.dart';
import 'package:reels_assignment/core/data/data_request.dart';
import 'package:reels_assignment/core/data/data_source_type.dart';
import 'package:reels_assignment/core/error/exceptions.dart';

class FirebaseDataClient extends AbstractDataClient {
  FirebaseDataClient({required this.firestore});

  final FirebaseFirestore firestore;

  @override
  DataSourceType get sourceType => DataSourceType.firebase;

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
      throw const DataClientException('id is required for Firebase get.');
    }

    try {
      final document = await firestore.collection(request.path).doc(id).get();
      if (!document.exists) {
        return null;
      }

      final data = document.data();
      if (data == null) {
        return null;
      }

      return <String, dynamic>{...data, 'id': document.id};
    } catch (error) {
      throw ServerException('Firebase get failed: $error');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getList(DataRequest request) async {
    try {
      Query<Map<String, dynamic>> query = firestore.collection(request.path);

      final filters = request.filters;
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }

      if (request.orderBy != null) {
        query = query.orderBy(request.orderBy!, descending: request.descending);
      }

      if (request.limit != null) {
        query = query.limit(request.limit!);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();
    } catch (error) {
      throw ServerException('Firebase getList failed: $error');
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
      throw const DataClientException('payload is required for Firebase post.');
    }

    try {
      await firestore.collection(request.path).add(payload);
    } catch (error) {
      throw ServerException('Firebase post failed: $error');
    }
  }

  @override
  Future<void> put(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for Firebase put.');
    }
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException('payload is required for Firebase put.');
    }

    try {
      await firestore.collection(request.path).doc(id).set(payload);
    } catch (error) {
      throw ServerException('Firebase put failed: $error');
    }
  }

  @override
  Future<void> patch(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for Firebase patch.');
    }
    final payload = request.payload;
    if (payload == null) {
      throw const DataClientException(
        'payload is required for Firebase patch.',
      );
    }

    try {
      await firestore
          .collection(request.path)
          .doc(id)
          .set(payload, SetOptions(merge: true));
    } catch (error) {
      throw ServerException('Firebase patch failed: $error');
    }
  }

  @override
  Future<void> upsert(DataRequest request) async {
    if (request.id == null) {
      await post(request);
      return;
    }
    await patch(request);
  }

  @override
  Future<void> delete(DataRequest request) async {
    final id = request.id;
    if (id == null) {
      throw const DataClientException('id is required for Firebase delete.');
    }

    try {
      await firestore.collection(request.path).doc(id).delete();
    } catch (error) {
      throw ServerException('Firebase delete failed: $error');
    }
  }
}
