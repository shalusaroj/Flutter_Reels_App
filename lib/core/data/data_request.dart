import 'package:reels_assignment/core/data/data_operation.dart';

class DataRequest {
  const DataRequest({
    required this.path,
    this.operation = DataOperation.get,
    this.id,
    this.payload,
    this.filters,
    this.orderBy,
    this.descending = false,
    this.limit,
  });

  final String path;
  final DataOperation operation;
  final String? id;
  final Map<String, dynamic>? payload;
  final Map<String, dynamic>? filters;
  final String? orderBy;
  final bool descending;
  final int? limit;

  DataRequest copyWith({
    String? path,
    DataOperation? operation,
    String? id,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool? descending,
    int? limit,
  }) {
    return DataRequest(
      path: path ?? this.path,
      operation: operation ?? this.operation,
      id: id ?? this.id,
      payload: payload ?? this.payload,
      filters: filters ?? this.filters,
      orderBy: orderBy ?? this.orderBy,
      descending: descending ?? this.descending,
      limit: limit ?? this.limit,
    );
  }
}
