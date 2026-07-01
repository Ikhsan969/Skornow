import 'package:isar_community/isar.dart';

part 'news_article_model.g.dart';

/// Model artikel berita bola, sekaligus berfungsi sebagai Isar Collection
/// (Single Source of Truth sesuai Aturan 1 modul).
///
/// PENTING: setelah edit file ini, wajib jalankan:
/// flutter pub run build_runner build --delete-conflicting-outputs
/// supaya file news_article_model.g.dart ter-generate ulang.
@collection
class NewsArticleModel {
  Id id = Isar.autoIncrement;

  /// ID unik dari sisi API (dipakai untuk upsert, hindari duplikat).
  @Index(unique: true, replace: true)
  late String articleId;

  late String title;

  String? description;

  String? content;

  late String url;

  String? imageUrl;

  late DateTime publishedAt;

  String? sourceName;

  /// Status bookmark artikel. Disimpan langsung di Isar supaya
  /// UI bisa reaktif otomatis (Stream) tanpa query tambahan.
  bool isBookmarked = false;

  NewsArticleModel();

  factory NewsArticleModel.fromGNewsJson(Map<String, dynamic> json) {
    final model = NewsArticleModel();
    model.articleId = (json['url'] as String? ?? '').isNotEmpty
        ? json['url'] as String
        : DateTime.now().millisecondsSinceEpoch.toString();
    model.title = json['title'] as String? ?? 'Tanpa judul';
    model.description = json['description'] as String?;
    model.content = json['content'] as String?;
    model.url = json['url'] as String? ?? '';
    model.imageUrl = json['image'] as String?;
    model.publishedAt = DateTime.tryParse(
          json['publishedAt'] as String? ?? '',
        ) ??
        DateTime.now();
    model.sourceName =
        (json['source'] as Map<String, dynamic>?)?['name'] as String?;
    return model;
  }
}
