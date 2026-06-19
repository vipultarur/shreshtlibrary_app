import 'package:dio/dio.dart';

class ApiFailure implements Exception {
  ApiFailure(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Object? errors;

  factory ApiFailure.fromDio(DioException error) {
    final payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      final message = payload['message']?.toString();
      final errors = payload.containsKey('errors') ? payload['errors'] : payload;
      return ApiFailure(
        message == null || message.isEmpty
            ? _messageFromErrors(errors)
            : message,
        statusCode: error.response?.statusCode,
        errors: errors,
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiFailure('Unable to reach the server. Check your connection.');
    }

    return ApiFailure(
      error.message ?? 'Something went wrong.',
      statusCode: error.response?.statusCode,
    );
  }

  static String _messageFromErrors(Object? errors) {
    if (errors is String && errors.isNotEmpty) {
      return errors;
    }
    if (errors is List && errors.isNotEmpty) {
      return errors.first.toString();
    }
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first is List && first.isNotEmpty) {
        return first.first.toString();
      }
      return first.toString();
    }
    return 'Something went wrong.';
  }

  @override
  String toString() => message;
}
