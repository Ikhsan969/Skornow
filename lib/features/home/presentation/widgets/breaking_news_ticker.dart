import 'package:flutter/material.dart';
import '../../../../core/realtime/breaking_news_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Widget Breaking News Ticker — menampilkan headline bola real-time
/// dari BreakingNewsService (WebSocket + Isolate-based stream).
///
/// Headline di-scroll secara horizontal menggunakan AnimationController
/// sehingga UI tetap fluid tanpa library tambahan.
class BreakingNewsTicker extends StatefulWidget {
  final BreakingNewsService service;

  const BreakingNewsTicker({super.key, required this.service});

  @override
  State<BreakingNewsTicker> createState() => _BreakingNewsTickerState();
}

class _BreakingNewsTickerState extends State<BreakingNewsTicker> {
  String _currentHeadline = 'Memuat berita terkini...';
  String _nextHeadline = '';
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    widget.service.breakingNewsStream.listen((headline) {
      if (!mounted) return;
      setState(() {
        _nextHeadline = headline;
        _isTransitioning = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _currentHeadline = _nextHeadline;
          _isTransitioning = false;
        });
      });
    });
    // Mulai koneksi WebSocket saat widget pertama kali tampil.
    widget.service.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      color: AppColors.primary,
      child: Row(
        children: [
          // Label "LIVE" badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            color: AppColors.red,
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
          // Divider
          Container(width: 1, height: 36, color: Colors.white24),
          // Scrolling headline
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Padding(
                key: ValueKey(_currentHeadline),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  _currentHeadline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
