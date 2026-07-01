import 'package:equatable/equatable.dart';
import '../../data/models/news_article_model.dart';

enum NewsStatus { initial, loading, success, error }

/// State Fail-Safe (Aturan 3 modul): selalu ada status loading/success/error,
/// tapi `articles` tetap dipertahankan walau status error supaya data lama
/// (dari Isar) tetap bisa ditampilkan ke pengguna saat internet mati.
class NewsState extends Equatable {
  final NewsStatus status;
  final List<NewsArticleModel> articles;
  final String? errorMessage;
  final bool isRefreshing;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  NewsState copyWith({
    NewsStatus? status,
    List<NewsArticleModel>? articles,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [status, articles, errorMessage, isRefreshing];
}
