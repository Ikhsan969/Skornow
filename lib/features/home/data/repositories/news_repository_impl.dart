import '../../domain/repositories/news_repository.dart';
import '../datasources/news_local_datasource.dart';
import '../datasources/news_remote_datasource.dart';
import '../models/news_article_model.dart';

/// Implementasi Offline-First (Aturan 2 modul):
/// (a) UI baca dari Isar lewat stream watchAllNews()
/// (b) refreshNewsFromApi() menembak Dio di background
/// (c) hasil baru disimpan ke Isar
/// (d) UI otomatis berubah sendiri karena stream reaktif dari Isar
class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  final NewsLocalDataSource localDataSource;

  NewsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Stream<List<NewsArticleModel>> watchAllNews() =>
      localDataSource.watchAllNews();

  @override
  Stream<List<NewsArticleModel>> watchBookmarkedNews() =>
      localDataSource.watchBookmarkedNews();

  @override
  Future<void> refreshNewsFromApi() async {
    final freshArticles = await remoteDataSource.fetchLatestFootballNews();
    await localDataSource.upsertAll(freshArticles);
  }

  @override
  Future<void> toggleBookmark(NewsArticleModel article) {
    return localDataSource.toggleBookmark(article);
  }
}
