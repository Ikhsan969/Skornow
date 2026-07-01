import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../network/api_client.dart';
import '../realtime/breaking_news_service.dart';
import '../../features/home/data/datasources/news_local_datasource.dart';
import '../../features/home/data/datasources/news_remote_datasource.dart';
import '../../features/home/data/models/news_article_model.dart';
import '../../features/home/data/repositories/news_repository_impl.dart';
import '../../features/home/domain/repositories/news_repository.dart';
import '../../features/home/presentation/cubit/news_cubit.dart';
import '../../features/bookmark/presentation/cubit/bookmark_cubit.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  // 1. Dio (Network)
  locator.registerLazySingleton<Dio>(() => ApiClient.createDio());

  // 2. Isar (Local Database)
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [NewsArticleModelSchema],
    directory: dir.path,
  );
  locator.registerLazySingleton<Isar>(() => isar);

  // 3. BreakingNewsService (WebSocket real-time)
  locator.registerLazySingleton<BreakingNewsService>(
    () => BreakingNewsService(),
  );

  // 4. Data Sources
  locator.registerLazySingleton<NewsRemoteDataSource>(
    () => NewsRemoteDataSourceImpl(locator<Dio>()),
  );
  locator.registerLazySingleton<NewsLocalDataSource>(
    () => NewsLocalDataSourceImpl(locator<Isar>()),
  );

  // 5. Repository
  locator.registerLazySingleton<NewsRepository>(
    () => NewsRepositoryImpl(
      remoteDataSource: locator<NewsRemoteDataSource>(),
      localDataSource: locator<NewsLocalDataSource>(),
    ),
  );

  // 6. Cubits (factory: di-create ulang tiap halaman dibuka)
  locator.registerFactory<NewsCubit>(
    () => NewsCubit(locator<NewsRepository>()),
  );
  locator.registerFactory<BookmarkCubit>(
    () => BookmarkCubit(locator<NewsRepository>()),
  );
}
