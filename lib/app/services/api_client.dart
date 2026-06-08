import 'package:dio/dio.dart';
import 'dart:async';

import 'app_config.dart';
import 'auth_token_storage.dart';

class ApiClient {
  static const _skipAuthFailureHandlingKey = 'skipAuthFailureHandling';

  ApiClient(this._authTokenStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authTokenStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final statusCode = error.response?.statusCode;
          final skipHandling =
              error.requestOptions.extra[_skipAuthFailureHandlingKey] == true;
          if (!skipHandling && (statusCode == 401 || statusCode == 403)) {
            _authFailuresController.add(
              ApiAuthFailure(
                statusCode: statusCode!,
                path: error.requestOptions.path,
              ),
            );
          }
          handler.next(error);
        },
      ),
    );
  }

  final AuthTokenStorage _authTokenStorage;
  final StreamController<ApiAuthFailure> _authFailuresController =
      StreamController<ApiAuthFailure>.broadcast();
  late final Dio _dio;

  Stream<ApiAuthFailure> get authFailures => _authFailuresController.stream;

  void dispose() {
    _authFailuresController.close();
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuthFailureHandling = false,
  }) async {
    try {
      return await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: skipAuthFailureHandling
            ? Options(extra: {_skipAuthFailureHandlingKey: true})
            : null,
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuthFailureHandling = false,
  }) async {
    try {
      return await _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: skipAuthFailureHandling
            ? Options(extra: {_skipAuthFailureHandlingKey: true})
            : null,
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool skipAuthFailureHandling = false,
  }) async {
    try {
      return await _dio.patch<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: skipAuthFailureHandling
            ? Options(extra: {_skipAuthFailureHandlingKey: true})
            : null,
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool skipAuthFailureHandling = false,
  }) async {
    try {
      return await _dio.delete<dynamic>(
        path,
        queryParameters: queryParameters,
        options: skipAuthFailureHandling
            ? Options(extra: {_skipAuthFailureHandlingKey: true})
            : null,
      );
    } on DioException catch (error) {
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    return ApiException(
      _extractErrorMessage(error),
      statusCode: error.response?.statusCode,
    );
  }

  String _extractErrorMessage(DioException error) {
    final payload = error.response?.data;
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (payload is String && payload.isNotEmpty) {
      return payload;
    }

    return error.message ?? 'Request failed.';
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiAuthFailure {
  const ApiAuthFailure({
    required this.statusCode,
    required this.path,
  });

  final int statusCode;
  final String path;
}
