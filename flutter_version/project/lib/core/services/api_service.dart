import 'package:dio/dio.dart';

import '../models/book.dart';
import '../utils/app_config.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<List<Book>> getBooks() async {
    try {
      final response = await _dio.get('/api/books');
      final List<dynamic> data = response.data;
      return data.map((json) => Book.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Book> getBook(String isbn) async {
    try {
      final response = await _dio.get('/api/books/$isbn');
      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Book> createBook(Book book) async {
    try {
      final response = await _dio.post(
        '/api/books',
        data: book.toJson(),
      );
      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Book> updateBook(Book book) async {
    try {
      final response = await _dio.put(
        '/api/books/${book.isbn}',
        data: book.toJson(),
      );
      return Book.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteBook(String isbn) async {
    try {
      await _dio.delete('/api/books/$isbn');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timeout. Please check your internet connection.');
    } else if (e.type == DioExceptionType.badResponse) {
      final int? statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return Exception('Resource not found');
      } else if (statusCode == 400) {
        return Exception('Invalid request');
      } else if (statusCode == 500) {
        return Exception('Server error. Please try again later.');
      }
    }
    return Exception('An error occurred: ${e.message}');
  }
}