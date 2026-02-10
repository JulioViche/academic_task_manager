import 'package:uuid/uuid.dart';

/// Model representing a sync operation queued for later processing
class SyncOperationModel {
  final String id;
  final String tableName;
  final String recordId;
  final String operationType; // 'create', 'update', 'delete'
  final String? jsonData;
  final DateTime createdAt;
  final String status; // 'pending', 'in_progress', 'completed', 'failed'
  final int retryCount;
  final int maxRetries;
  final String? errorMessage;
  final DateTime? lastAttemptedAt;

  const SyncOperationModel({
    required this.id,
    required this.tableName,
    required this.recordId,
    required this.operationType,
    this.jsonData,
    required this.createdAt,
    this.status = 'pending',
    this.retryCount = 0,
    this.maxRetries = 3,
    this.errorMessage,
    this.lastAttemptedAt,
  });

  /// Create a new sync operation with auto-generated ID
  factory SyncOperationModel.create({
    required String tableName,
    required String recordId,
    required String operationType,
    String? jsonData,
  }) {
    return SyncOperationModel(
      id: const Uuid().v4(),
      tableName: tableName,
      recordId: recordId,
      operationType: operationType,
      jsonData: jsonData,
      createdAt: DateTime.now(),
    );
  }

  factory SyncOperationModel.fromJson(Map<String, dynamic> json) {
    return SyncOperationModel(
      id: json['id'],
      tableName: json['table_name'],
      recordId: json['record_id'],
      operationType: json['operation_type'],
      jsonData: json['json_data'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at']),
      status: json['status'] ?? 'pending',
      retryCount: json['retry_count'] ?? 0,
      maxRetries: json['max_retries'] ?? 3,
      errorMessage: json['error_message'],
      lastAttemptedAt: json['last_attempted_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['last_attempted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_name': tableName,
      'record_id': recordId,
      'operation_type': operationType,
      'json_data': jsonData,
      'created_at': createdAt.millisecondsSinceEpoch,
      'status': status,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'error_message': errorMessage,
      'last_attempted_at': lastAttemptedAt?.millisecondsSinceEpoch,
    };
  }

  SyncOperationModel copyWith({
    String? status,
    int? retryCount,
    String? errorMessage,
    DateTime? lastAttemptedAt,
  }) {
    return SyncOperationModel(
      id: id,
      tableName: tableName,
      recordId: recordId,
      operationType: operationType,
      jsonData: jsonData,
      createdAt: createdAt,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
      errorMessage: errorMessage ?? this.errorMessage,
      lastAttemptedAt: lastAttemptedAt ?? this.lastAttemptedAt,
    );
  }

  /// Whether this operation can still be retried
  bool get canRetry => retryCount < maxRetries;

  @override
  String toString() =>
      'SyncOperation($operationType $tableName/$recordId status=$status retries=$retryCount)';
}
