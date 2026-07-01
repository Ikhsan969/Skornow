import 'package:flutter/material.dart';
import '../../data/models/news_article_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_theme.dart';

class NewsCard extends StatelessWidget {
  final NewsArticleModel article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const NewsCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail gambar (kiri)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(
                          article.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Konten teks (kanan)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Source badge
                    if (article.sourceName != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          article.sourceName!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                    // Judul artikel
                    Text(
                      article.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Waktu + bookmark
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formatTimeAgo(article.publishedAt),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onBookmarkTap,
                          child: Icon(
                            article.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 18,
                            color: article.isBookmarked
                                ? AppColors.accent
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.cardDark,
      child: const Icon(
        Icons.sports_soccer,
        color: AppColors.borderDark,
        size: 32,
      ),
    );
  }
}
