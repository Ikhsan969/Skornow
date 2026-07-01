import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/realtime/breaking_news_service.dart';
import 'features/home/presentation/cubit/news_cubit.dart';
import 'features/bookmark/presentation/cubit/bookmark_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Paksa orientasi portrait (umum di aplikasi berita)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Styling status bar agar transparan (sesuai dark mode)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Setup seluruh Dependency Injection
  await setupLocator();

  runApp(const SkorNowApp());
}

class SkorNowApp extends StatefulWidget {
  const SkorNowApp({super.key});

  @override
  State<SkorNowApp> createState() => _SkorNowAppState();
}

class _SkorNowAppState extends State<SkorNowApp> {
  @override
  void dispose() {
    // Bersihkan WebSocket connection saat aplikasi ditutup
    locator<BreakingNewsService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NewsCubit>(create: (_) => locator<NewsCubit>()),
        BlocProvider<BookmarkCubit>(create: (_) => locator<BookmarkCubit>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'SkorNow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        // Wajib Dark Mode (NIM ganjil) — sesuai aturan anti-plagiasi modul
        themeMode: AppTheme.requiredThemeMode,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
