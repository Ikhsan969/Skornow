import '../../data/models/news_article_model.dart';

/// Kontrak repository. Cubit HANYA boleh bicara lewat interface ini,
/// tidak boleh langsung memanggil Dio() atau Isar() (Aturan 1 modul).
abstract class NewsRepository {
  Stream<List<NewsArticleModel>> watchAllNews();
  Stream<List<NewsArticleModel>> watchBookmarkedNews();

  /// Menembak API di background lalu menyimpan hasilnya ke Isar.
  /// UI tidak perlu menunggu ini selesai untuk menampilkan data
  /// (data lokal sudah tampil duluan lewat watchAllNews).
  Future<void> refreshNewsFromApi();

  Future<void> toggleBookmark(NewsArticleModel article);
}
