import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../cubit/bookmark_cubit.dart';
import '../../../home/presentation/widgets/news_card.dart';
import '../../../../core/theme/app_theme.dart';

class BookmarkPage extends StatelessWidget {
  const BookmarkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Tersimpan 🔖'),
      ),
      body: BlocBuilder<BookmarkCubit, BookmarkState>(
        builder: (context, state) {
          if (state.status == BookmarkStatus.loading) {
            return Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 100,
                height: 100,
                errorBuilder: (_, __, ___) =>
                    const CircularProgressIndicator(color: AppColors.primary),
              ),
            );
          }

          if (state.bookmarks.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_border_rounded,
                      size: 80,
                      color: AppColors.borderDark,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum ada berita disimpan',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap ikon bookmark 🔖 di kartu berita\nuntuk menyimpan dan membaca offline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.sports_soccer, size: 18),
                      label: const Text(
                        'Lihat Berita',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: state.bookmarks.length,
            itemBuilder: (context, index) {
              final article = state.bookmarks[index];
              return NewsCard(
                article: article,
                onTap: () => context.push('/detail', extra: article),
                onBookmarkTap: () =>
                    context.read<BookmarkCubit>().removeBookmark(article),
              );
            },
          );
        },
      ),
    );
  }
}
