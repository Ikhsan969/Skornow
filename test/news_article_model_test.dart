import 'package:flutter_test/flutter_test.dart';
import 'package:skornow/features/home/data/models/news_article_model.dart';

void main() {
  group('NewsArticleModel.fromGNewsJson', () {
    test('berhasil parsing JSON GNews yang lengkap', () {
      final json = {
        'title': 'Timnas Menang 3-0',
        'description': 'Ringkasan pertandingan timnas semalam.',
        'content': 'Isi lengkap berita pertandingan...',
        'url': 'https://example.com/berita/timnas-menang',
        'image': 'https://example.com/image.jpg',
        'publishedAt': '2026-06-29T10:00:00Z',
        'source': {'name': 'Bola Sport', 'url': 'https://example.com'},
      };

      final model = NewsArticleModel.fromGNewsJson(json);

      expect(model.articleId, 'https://example.com/berita/timnas-menang');
      expect(model.title, 'Timnas Menang 3-0');
      expect(model.description, 'Ringkasan pertandingan timnas semalam.');
      expect(model.sourceName, 'Bola Sport');
      expect(model.publishedAt, DateTime.parse('2026-06-29T10:00:00Z'));
      // Status bookmark wajib default false saat baru di-fetch dari API.
      expect(model.isBookmarked, false);
    });

    test('tetap aman (fallback) saat field opsional kosong/null', () {
      final json = <String, dynamic>{
        'title': null,
        'url': '',
        'publishedAt': null,
        'source': null,
      };

      final model = NewsArticleModel.fromGNewsJson(json);

      expect(model.title, 'Tanpa judul');
      expect(model.sourceName, isNull);
      expect(model.articleId.isNotEmpty, true);
      expect(model.isBookmarked, false);
    });
  });
}
