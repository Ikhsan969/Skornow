import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../cubit/news_cubit.dart';
import '../cubit/news_state.dart';
import '../widgets/news_card.dart';
import '../widgets/featured_article_card.dart';
import '../widgets/breaking_news_ticker.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/realtime/breaking_news_service.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'SKOR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'NOW',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ),
        actions: [
          BlocBuilder<NewsCubit, NewsState>(
            builder: (context, state) {
              if (state.isRefreshing) {
                return const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => context.read<NewsCubit>().refresh(),
                tooltip: 'Refresh berita',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Breaking News Ticker (WebSocket real-time)
          BreakingNewsTicker(service: locator<BreakingNewsService>()),

          // Konten utama
          Expanded(
            child: BlocBuilder<NewsCubit, NewsState>(
              builder: (context, state) {
                // ── Loading awal (Isar belum ada data sama sekali) ──
                if (state.status == NewsStatus.loading &&
                    state.articles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(
                          'assets/lottie/loading.json',
                          width: 120,
                          height: 120,
                          errorBuilder: (_, __, ___) =>
                              const CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Memuat berita bola...',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                // ── Error total (tidak ada data Isar + network gagal) ──
                if (state.status == NewsStatus.error &&
                    state.articles.isEmpty) {
                  return _ErrorView(
                    message: state.errorMessage ??
                        'Gagal memuat berita. Cek koneksi internet.',
                    onRetry: () => context.read<NewsCubit>().refresh(),
                  );
                }

                // ── Empty state ──
                if (state.articles.isEmpty) {
                  return _EmptyView(
                    onRetry: () => context.read<NewsCubit>().refresh(),
                  );
                }

                // ── Berhasil: tampilkan daftar berita ──
                return RefreshIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.cardDark,
                  onRefresh: () => context.read<NewsCubit>().refresh(),
                  child: CustomScrollView(
                    slivers: [
                      // Banner error offline (data lama masih tampil)
                      if (state.errorMessage != null)
                        SliverToBoxAdapter(
                          child: _OfflineBanner(
                              message: state.errorMessage!),
                        ),

                      // Featured article (artikel pertama sebagai hero)
                      SliverToBoxAdapter(
                        child: FeaturedArticleCard(
                          article: state.articles.first,
                          onTap: () => context.push(
                            '/detail',
                            extra: state.articles.first,
                          ),
                          onBookmarkTap: () => context
                              .read<NewsCubit>()
                              .toggleBookmark(state.articles.first),
                        ),
                      ),

                      // Section header
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                          child: Row(
                            children: [
                              Text(
                                'Berita Terbaru',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('⚽',
                                  style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                      ),

                      // Daftar artikel (skip artikel pertama, sudah jadi hero)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = state.articles[index + 1];
                            return NewsCard(
                              article: article,
                              onTap: () =>
                                  context.push('/detail', extra: article),
                              onBookmarkTap: () => context
                                  .read<NewsCubit>()
                                  .toggleBookmark(article),
                            );
                          },
                          childCount:
                              (state.articles.length - 1).clamp(0, 999),
                        ),
                      ),

                      // Bottom padding
                      const SliverToBoxAdapter(
                          child: SizedBox(height: 24)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _OfflineBanner extends StatelessWidget {
  final String message;
  const _OfflineBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.red.withOpacity(0.9),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/error.json',
              width: 120,
              height: 120,
              repeat: true,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Coba Lagi',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onRetry;
  const _EmptyView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sports_soccer,
                size: 72, color: AppColors.borderDark),
            const SizedBox(height: 16),
            const Text(
              'Belum ada berita tersimpan.',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan koneksi internet aktif\nlalu muat berita terbaru.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Muat Berita',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
