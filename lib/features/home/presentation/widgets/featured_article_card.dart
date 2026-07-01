import 'package:flutter/material.dart';
import '../../data/models/news_article_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_theme.dart';

/// Kartu hero artikel utama — ditampilkan paling atas daftar berita
/// dengan desain full-bleed image + gradient overlay.
class FeaturedArticleCard extends StatelessWidget {
  final NewsArticleModel article;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const FeaturedArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image
                if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                  Image.network(
                    article.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.cardDark,
                      child: const Icon(
                        Icons.sports_soccer,
                        size: 64,
                        color: AppColors.borderDark,
                      ),
                    ),
                  )
                else
                  Container(
                    color: AppColors.cardDark,
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 64,
                      color: AppColors.borderDark,
                    ),
                  ),

                // Gradient overlay (bottom ke atas)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // Konten teks di atas overlay
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge "UTAMA" di kiri atas
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '⚽ UTAMA',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      // Judul + meta di bawah
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${article.sourceName ?? 'SkorNow'} · ${formatTimeAgo(article.publishedAt)}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.75),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Bookmark button
                              GestureDetector(
                                onTap: onBookmarkTap,
                                child: Icon(
                                  article.isBookmarked
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  color: article.isBookmarked
                                      ? AppColors.accent
                                      : Colors.white70,
                                  size: 22,
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
