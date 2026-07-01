import 'package:isar_community/isar.dart';
import '../models/news_article_model.dart';

abstract class NewsLocalDataSource {
  Stream<List<NewsArticleModel>> watchAllNews();
  Stream<List<NewsArticleModel>> watchBookmarkedNews();
  Future<List<NewsArticleModel>> getAllNews();
  Future<void> upsertAll(List<NewsArticleModel> articles);
  Future<void> toggleBookmark(NewsArticleModel article);
}

/// Implementasi nyata Isar Database (Aturan 2: Offline-First Paradigm).
class NewsLocalDataSourceImpl implements NewsLocalDataSource {
  final Isar isar;

  NewsLocalDataSourceImpl(this.isar);

  @override
  Stream<List<NewsArticleModel>> watchAllNews() {
    return isar.newsArticleModels
        .where()
        .sortByPublishedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<NewsArticleModel>> watchBookmarkedNews() {
    return isar.newsArticleModels
        .filter()
        .isBookmarkedEqualTo(true)
        .sortByPublishedAtDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<NewsArticleModel>> getAllNews() {
    return isar.newsArticleModels.where().sortByPublishedAtDesc().findAll();
  }

  @override
  Future<void> upsertAll(List<NewsArticleModel> articles) async {
    await isar.writeTxn(() async {
      // Pertahankan status bookmark lama jika artikel sudah ada.
      for (final incoming in articles) {
        final existing = await isar.newsArticleModels
            .filter()
            .articleIdEqualTo(incoming.articleId)
            .findFirst();
        if (existing != null) {
          incoming.id = existing.id;
          incoming.isBookmarked = existing.isBookmarked;
        }
      }
      await isar.newsArticleModels.putAll(articles);
    });
  }

  @override
  Future<void> toggleBookmark(NewsArticleModel article) async {
    await isar.writeTxn(() async {
      article.isBookmarked = !article.isBookmarked;
      await isar.newsArticleModels.put(article);
    });
  }
}
