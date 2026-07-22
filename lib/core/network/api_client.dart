import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:dio/dio.dart';

import 'package:shreshtlibrary/core/errors/api_failure.dart';
import 'package:shreshtlibrary/core/network/token_store.dart';

typedef JsonMap = Map<String, dynamic>;
typedef JsonParser<T> = T Function(Object? data);

class _ParseArgs<T> {
  const _ParseArgs(this.rows, this.parser);
  final List<JsonMap> rows;
  final T Function(JsonMap json) parser;
}

List<T> _parseList<T>(_ParseArgs<T> args) {
  return args.rows.map(args.parser).toList();
}

class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenStore, Dio? dio})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    _refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
    this.dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: _addAuthHeader,
        onError: _handleAuthError,
      ),
    );
    final logInterceptor = LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    );
    this.dio.interceptors.add(logInterceptor);
    _refreshDio.interceptors.add(logInterceptor);
  }

  final String baseUrl;
  final TokenStore tokenStore;
  final Dio dio;
  late final Dio _refreshDio;
  Future<String?>? _refreshFuture;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _guard(() => dio.get<T>(path, queryParameters: query));
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _guard(() => dio.post<T>(path, data: data ?? <String, dynamic>{}));
  }

  Future<Response<T>> put<T>(String path, {Object? data}) {
    return _guard(() => dio.put<T>(path, data: data ?? <String, dynamic>{}));
  }

  Future<Response<T>> delete<T>(String path, {Object? data}) {
    return _guard(() => dio.delete<T>(path, data: data));
  }

  Future<void> close() async {
    dio.close();
    _refreshDio.close();
  }

  T unwrap<T>(Response<dynamic> response, JsonParser<T> parser) {
    final payload = response.data;
    if (payload is JsonMap) {
      if (payload['success'] == false || payload['status'] == 'error') {
        throw ApiFailure(
          payload['message']?.toString() ?? 'Request failed.',
          errors: payload['errors'],
          code: payload['code']?.toString(),
        );
      }
      return parser(payload.containsKey('data') ? payload['data'] : payload);
    }
    return parser(payload);
  }

  Future<List<T>> unwrapList<T>(
    Response<dynamic> response,
    T Function(JsonMap json) parser,
  ) async {
    return unwrap<Future<List<T>>>(response, (data) async {
      List<dynamic> rows = [];
      if (data is List) {
        rows = data;
      } else if (data is JsonMap) {
        if (data.containsKey('data') && data['data'] is List) {
          rows = data['data'] as List<dynamic>;
        } else if (data.containsKey('results') && data['results'] is List) {
          rows = data['results'] as List<dynamic>;
        }
      }
      final validRows = rows.whereType<JsonMap>().toList();
      if (validRows.length > 50) {
        // PERF: moved off main thread
        return await compute(_parseList<T>, _ParseArgs<T>(validRows, parser));
      }
      return validRows.map(parser).toList();
    });
  }

  Future<T> _guard<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      throw ApiFailure.fromDio(error);
    }
  }

  Future<void> _addAuthHeader(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await tokenStore.read();
    if (tokens?.access.isNotEmpty ?? false) {
      options.headers['Authorization'] = 'Bearer ${tokens!.access}';
    }
    handler.next(options);
  }

  Future<void> _handleAuthError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final request = error.requestOptions;
    final isRefresh = request.path.contains('/auth/token/refresh');
    final alreadyRetried = request.extra['retried'] == true;

    if (error.response?.statusCode == 401 && !isRefresh && !alreadyRetried) {
      final nextAccess = await _refreshAccessToken();
      if (nextAccess != null) {
        request.extra['retried'] = true;
        request.headers['Authorization'] = 'Bearer $nextAccess';
        try {
          final response = await dio.fetch<dynamic>(request);
          handler.resolve(response);
          return;
        } on DioException catch (retryError) {
          handler.next(retryError);
          return;
        }
      }
      await tokenStore.clear();
    }

    handler.next(error);
  }

  Future<String?> _refreshAccessToken() async {
    final tokens = await tokenStore.read();
    if (tokens == null || tokens.refresh.isEmpty) {
      return null;
    }

    _refreshFuture ??= _refreshDio
        .post<dynamic>('/auth/token/refresh', data: {'refresh': tokens.refresh})
        .then((response) async {
          final payload = response.data;
          String? access;
          if (payload is JsonMap) {
            final dataObj = payload['data'];
            if (dataObj is JsonMap) {
              access = dataObj['access']?.toString();
            } else {
              access = payload['access']?.toString();
            }
          }
          if (access == null || access.isEmpty) {
            return null;
          }
          await tokenStore.saveAccess(access);
          return access;
        })
        .catchError((Object _) async {
          await tokenStore.clear();
          return null;
        })
        .whenComplete(() {
          _refreshFuture = null;
        });

    return _refreshFuture;
  }
}
