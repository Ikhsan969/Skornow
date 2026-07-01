import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../home/data/models/news_article_model.dart';
import '../../../home/domain/repositories/news_repository.dart';

enum BookmarkStatus { loading, success }

class BookmarkState extends Equatable {
  final BookmarkStatus status;
  final List<NewsArticleModel> bookmarks;

  const BookmarkState({
    this.status = BookmarkStatus.loading,
    this.bookmarks = const [],
  });

  BookmarkState copyWith({
    BookmarkStatus? status,
    List<NewsArticleModel>? bookmarks,
  }) {
    return BookmarkState(
      status: status ?? this.status,
      bookmarks: bookmarks ?? this.bookmarks,
    );
  }

  @override
  List<Object?> get props => [status, bookmarks];
}

/// Cubit khusus halaman Bookmark. Tetap lewat NewsRepository yang sama
/// (Single Source of Truth) -- tidak membuat akses Isar baru.
class BookmarkCubit extends Cubit<BookmarkState> {
  final NewsRepository repository;
  StreamSubscription<List<NewsArticleModel>>? _subscription;

  BookmarkCubit(this.repository) : super(const BookmarkState()) {
    _subscription = repository.watchBookmarkedNews().listen((bookmarks) {
      emit(state.copyWith(
        status: BookmarkStatus.success,
        bookmarks: bookmarks,
      ));
    });
  }

  Future<void> removeBookmark(NewsArticleModel article) {
    return repository.toggleBookmark(article);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
