import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/news_article_model.dart';
import '../../domain/repositories/news_repository.dart';
import 'news_state.dart';

/// Cubit untuk halaman Home. UI (HomePage) HANYA boleh bicara ke Cubit ini,
/// tidak boleh memanggil Repository/Dio/Isar langsung (Aturan 1 modul).
class NewsCubit extends Cubit<NewsState> {
  final NewsRepository repository;
  StreamSubscription<List<NewsArticleModel>>? _newsSubscription;

  NewsCubit(this.repository) : super(const NewsState()) {
    _listenToLocalNews();
  }

  void _listenToLocalNews() {
    emit(state.copyWith(status: NewsStatus.loading));
    _newsSubscription = repository.watchAllNews().listen((articles) {
      emit(state.copyWith(
        status: NewsStatus.success,
        articles: articles,
      ));
    });
    // Setelah data lokal tampil duluan, tembak API di background.
    refresh();
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true, errorMessage: null));
    try {
      await repository.refreshNewsFromApi();
      emit(state.copyWith(isRefreshing: false, errorMessage: null));
    } catch (e) {
      // Fail-Safe: data lama (state.articles) tetap dipertahankan,
      // hanya tampilkan pesan error di atasnya.
      emit(state.copyWith(
        isRefreshing: false,
        status: state.articles.isEmpty ? NewsStatus.error : state.status,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> toggleBookmark(NewsArticleModel article) {
    return repository.toggleBookmark(article);
  }

  @override
  Future<void> close() {
    _newsSubscription?.cancel();
    return super.close();
  }
}
