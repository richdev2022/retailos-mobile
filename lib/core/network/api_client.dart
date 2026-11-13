import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/env.dart';
import '../storage/secure_storage.dart';

/// Wrapper around [Dio] that:
/// - attaches `Authorization: Bearer <access_token>` to every request
/// - attaches `X-Business-Id` and `X-Branch-Id` headers when set
/// - refreshes the access token (single-flight) on 401 and retries the original
///   request
/// - maps Dio errors to a typed [ApiError]
class ApiClient {
  ApiClient({required String baseUrl, required this.ref})
      : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            headers: <String, dynamic>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            responseType: ResponseType.json,
            validateStatus: (_) => true, // we handle all status codes manually
          ),
        ) {
    _dio.interceptors.add(_AuthInterceptor(ref: ref, dio: _dio));
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: false,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (o) => debugPrint('[http] $o'),
          maxWidth: 120,
        ),
      );
    }
  }

  final Dio _dio;
  final Ref ref;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get<T>(path, queryParameters: queryParameters, options: options);

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.patch<T>(path, data: data, queryParameters: queryParameters, options: options);

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.delete<T>(path, data: data, queryParameters: queryParameters, options: options);

  /// Unwraps a standard RetailOS success envelope:
  /// { success: true, message: "...", data: ... }
  T unwrap<T>(Response<dynamic> response, T Function(dynamic data) mapper) {
    if (response.statusCode == null || response.statusCode! >= 400) {
      throw ApiError.fromResponse(response);
    }
    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw ApiError(message: 'Unexpected response format', code: 'BAD_RESPONSE', statusCode: response.statusCode ?? 0);
    }
    final success = body['success'] as bool? ?? false;
    if (!success) {
      throw ApiError(
        message: body['message'] as String? ?? 'Request failed',
        code: body['code'] as String? ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 0,
        details: body['errors'],
      );
    }
    return mapper(body['data']);
  }

  /// Unwraps a paginated list response.
  PaginatedResponse<T> unwrapList<T>(Response<dynamic> response, T Function(List<dynamic> items) mapper) {
    if (response.statusCode == null || response.statusCode! >= 400) {
      throw ApiError.fromResponse(response);
    }
    final body = response.data as Map<String, dynamic>;
    final success = body['success'] as bool? ?? false;
    if (!success) {
      throw ApiError(
        message: body['message'] as String? ?? 'Request failed',
        code: body['code'] as String? ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 0,
      );
    }
    final data = (body['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
    return PaginatedResponse<T>(
      items: mapper(data['items'] as List<dynamic>? ?? const <dynamic>[]),
      total: (data['total'] as num?)?.toInt() ?? 0,
      page: (data['page'] as num?)?.toInt() ?? 1,
      limit: (data['limit'] as num?)?.toInt() ?? 20,
      pages: (data['pages'] as num?)?.toInt() ?? 1,
    );
  }
}

class PaginatedResponse<T> {
  PaginatedResponse({required this.items, required this.total, required this.page, required this.limit, required this.pages});
  final List<T> items;
  final int total;
  final int page;
  final int limit;
  final int pages;
}

class ApiError implements Exception {
  ApiError({required this.message, this.code = 'UNKNOWN', this.statusCode = 0, this.details});
  final String message;
  final String code;
  final int statusCode;
  final dynamic details;

  factory ApiError.fromResponse(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      return ApiError(
        message: body['message'] as String? ?? 'Request failed',
        code: body['code'] as String? ?? 'UNKNOWN',
        statusCode: response.statusCode ?? 0,
        details: body['errors'],
      );
    }
    return ApiError(
      message: 'HTTP ${response.statusCode}: ${response.statusMessage ?? ''}',
      code: 'HTTP_ERROR',
      statusCode: response.statusCode ?? 0,
    );
  }

  @override
  String toString() => 'ApiError($code, $statusCode): $message';
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({required this.ref, required this.dio});

  final Ref ref;
  final Dio dio;
  bool _refreshing = false;
  final _pending = <Future<void> Function()>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    final businessId = await SecureStorage.getActiveBusinessId();
    if (businessId != null) {
      options.headers['X-Business-Id'] = businessId;
    }
    final branchId = await SecureStorage.getActiveBranchId();
    if (branchId != null) {
      options.headers['X-Branch-Id'] = branchId;
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isAuthErr = err.response?.statusCode == 401;
    final path = err.requestOptions.path;
    final isAuthRoute = path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/reset-password');
    if (!isAuthErr || isAuthRoute) {
      return handler.next(err);
    }

    // Single-flight refresh
    try {
      final newToken = await _refreshTokenSingleFlight();
      if (newToken == null) {
        return handler.next(err);
      }
      // Retry original
      final clone = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken';
      final response = await dio.fetch(clone);
      return handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String?> _refreshTokenSingleFlight() async {
    if (_refreshing) {
      // Wait until the inflight refresh completes
      final completer = <Future<void> Function()>[];
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return SecureStorage.getAccessToken();
    }
    _refreshing = true;
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return null;
      final response = await Dio().post<dynamic>(
        '${Env.apiBaseUrl}/auth/refresh',
        data: <String, dynamic>{'refreshToken': refreshToken},
        options: Options(
          headers: <String, dynamic>{'Accept': 'application/json'},
          validateStatus: (_) => true,
        ),
      );
      if (response.statusCode != 200) {
        await SecureStorage.clearAuth();
        return null;
      }
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? <String, dynamic>{}) as Map<String, dynamic>;
      final newAccess = data['accessToken'] as String?;
      if (newAccess == null) return null;
      await SecureStorage.setAccessToken(newAccess);
      return newAccess;
    } catch (e) {
      return null;
    } finally {
      _refreshing = false;
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: Env.apiBaseUrl, ref: ref);
});
