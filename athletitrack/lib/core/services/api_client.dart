import 'package:dio/dio.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    // On Linux and some other systems, 127.0.0.1 is more reliable than localhost
    // due to IPv6 resolution issues with XAMPP/LAMPP
    String baseUrl = 'http://127.0.0.1/athletitrack-api';
    if (!kIsWeb && Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2/athletitrack-api';
    }

    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
        // Accept ALL status codes — PHP uses 4xx/5xx for business logic errors.
        // Flutter reads the JSON body (status/message) to determine success/failure.
        validateStatus: (status) => true,
      ),
    );
  }

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}
