import 'package:dio/dio.dart';
import '../config/env_config.dart';

/// Wrapper Dio Client. UI dan layer lain DILARANG memanggil Dio() langsung
/// (Aturan 1: Single Source of Truth) -- semua akses lewat Repository.
class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: !EnvConfig.isProduction,
        responseBody: !EnvConfig.isProduction,
      ),
    );

    return dio;
  }
}
