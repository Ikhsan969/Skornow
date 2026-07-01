import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/news_article_model.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubit/news_cubit.dart';

class NewsDetailPage extends StatelessWidget {
  final NewsArticleModel article;
  const NewsDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: CustomScrollView(
        slivers: [
          // Hero AppBar dengan gambar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.surfaceDark,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () =>
                    context.read<NewsCubit>().toggleBookmark(article),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    article.isBookmarked
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                    color: article.isBookmarked
                        ? AppColors.accent
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (article.imageUrl != null &&
                      article.imageUrl!.isNotEmpty)
                    Image.network(
                      article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.cardDark,
                        child: const Icon(Icons.sports_soccer,
                            size: 80, color: AppColors.borderDark),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.cardDark,
                      child: const Icon(Icons.sports_soccer,
                          size: 80, color: AppColors.borderDark),
                    ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten artikel
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source + waktu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          article.sourceName ?? 'SkorNow',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        formatTimeAgo(article.publishedAt),
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Judul
                  Text(
                    article.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider dekoratif
                  Row(
                    children: [
                      Container(
                          width: 4, height: 4,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Container(height: 1, width: 40, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Container(
                          width: 4, height: 4,
                          decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi (lead)
                  if (article.description != null) ...[
                    Text(
                      article.description!,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Isi konten
                  Text(
                    article.content ??
                        'Konten lengkap tidak tersedia pada free tier API GNews.\n\n'
                            'Klik tombol di bawah untuk membaca artikel lengkap di sumbernya.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol baca selengkapnya
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Di production: buka URL artikel di browser
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('URL: ${article.url}'),
                            backgroundColor: AppColors.cardDark,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_browser_rounded,
                          size: 18),
                      label: const Text(
                        'Baca Selengkapnya di Sumber',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
