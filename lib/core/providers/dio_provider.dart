import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';

// Provider del cliente Dio
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}${ApiConstants.apiVersion}',
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Logger para debug
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      compact: true,
    ),
  );

  // Interceptor para agregar token automáticamente
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Aquí agregarás el token cuando implementes auth
        // final token = ref.read(authTokenProvider);
        // if (token != null) {
        //   options.headers['Authorization'] = 'Bearer $token';
        // }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Manejo de errores global
        if (error.response?.statusCode == 401) {
          // Token expirado, intentar refresh
          // await ref.read(authProvider.notifier).refreshToken();
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
