import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // untuk compute (Isolate wrapper)
import '../../../../core/config/env_config.dart';
import '../../../../core/network/app_exception.dart';
import '../models/news_article_model.dart';

abstract class NewsRemoteDataSource {
  Future<List<NewsArticleModel>> fetchLatestFootballNews();
}

/// Top-level function (WAJIB di luar class) agar bisa dipakai oleh compute().
/// compute() = Flutter wrapper untuk menjalankan fungsi di Isolate terpisah,
/// sehingga parsing JSON berat tidak memblokir UI thread (Aturan modul Pertemuan 5).
///
/// Mengapa top-level? Isolate tidak bisa akses closure atau method instance class.
List<NewsArticleModel> _parseArticlesInIsolate(Map<String, dynamic> responseData) {
  final List<dynamic> articlesJson =
      responseData['articles'] as List<dynamic>? ?? [];
  return articlesJson
      .map((json) => NewsArticleModel.fromGNewsJson(json as Map<String, dynamic>))
      .toList();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final Dio dio;
  NewsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NewsArticleModel>> fetchLatestFootballNews() async {
    try {
      final response = await dio.get(
        '/top-headlines',
        queryParameters: {
          'category': EnvConfig.newsCategory,
          'q': EnvConfig.newsQuery,
          'lang': EnvConfig.newsLang,
          'apikey': EnvConfig.gnewsApiKey,
          'max': 25,
        },
      );

      // Isolate: parsing JSON berat dijalankan di background thread
      // supaya list berita (25+ artikel) tidak membuat UI scroll terasa lag.
      final articles = await compute(
        _parseArticlesInIsolate,
        Map<String, dynamic>.from(response.data as Map),
      );

      return articles;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkFailureException();
      }
      throw ServerFailureException(
        e.response?.data?['errors']?.toString(),
      );
    }
  }
}
