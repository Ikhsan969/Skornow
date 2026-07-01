# SkorNow ⚽

Portal Berita Bola Offline-First — Final Project (UAS) Mobile Programming Lanjut  
**S1 Informatika — Universitas Teknologi Digital**

---

## Arsitektur

Clean Architecture sesuai modul kuliah:

```
lib/
├─ core/
│  ├─ config/      → EnvConfig (DEV/PROD), NimConfig (aturan dark/light mode)
│  ├─ di/          → GetIt setup (injection.dart)
│  ├─ network/     → Dio client + custom exceptions
│  ├─ realtime/    → BreakingNewsService (WebSocket + Isolate)
│  ├─ routing/     → go_router + bottom nav shell
│  ├─ theme/       → AppTheme + AppColors (dark mode wajib karena NIM ganjil)
│  └─ utils/       → date_formatter (pure function, dipakai di unit test)
├─ features/
│  ├─ home/
│  │  ├─ data/     → NewsArticleModel (Isar), datasources, repository impl
│  │  ├─ domain/   → NewsRepository interface
│  │  └─ presentation/ → NewsCubit, HomePage, NewsDetailPage, widgets
│  ├─ bookmark/    → BookmarkCubit + BookmarkPage
│  └─ settings/    → SettingsPage (info env, NIM, teknologi, MethodChannel)
└─ main.dart
```

---

## 7 Teknologi Wajib Modul (Pertemuan 1–14)

| Teknologi | Implementasi di SkorNow |
|---|---|
| Clean Architecture + GetIt + go_router | ✅ `core/di/`, `core/routing/`, struktur `data/domain/presentation` |
| Dio Interceptors | ✅ `ApiClient.createDio()` dengan LogInterceptor |
| BLoC / Cubit | ✅ `NewsCubit`, `BookmarkCubit` |
| Isar (Offline-First) | ✅ `NewsArticleModel`, `NewsLocalDataSourceImpl` |
| Isolates | ✅ `compute()` di `news_remote_datasource.dart` (background JSON parsing) |
| WebSockets | ✅ `BreakingNewsService` (dart:io WebSocket + fallback timer) |
| Lottie | ✅ `assets/lottie/loading.json` & `error.json` di HomePage & BookmarkPage |
| MethodChannel | 📋 Dijelaskan di halaman Settings + README (lihat bagian bawah) |

---

## 3 Aturan Integrasi (Golden Rules)

- **Aturan 1 — Single Source of Truth**: UI → Cubit → Repository. Tidak ada widget yang panggil `Dio()`/`Isar()` langsung.
- **Aturan 2 — Offline-First**: Isar tampil duluan via `watchAllNews()` Stream, lalu `NewsCubit` fetch GNews di background via `compute()`, hasil disimpan ke Isar, UI auto-update.
- **Aturan 3 — Fail-Safe UI**: Setiap state ada Loading (Lottie) / Success / Error (Lottie + banner merah), data lama tetap tampil walau internet mati.

---

## Setup Awal

**1. Prasyarat**
- Flutter SDK stable terbaru
- Android Studio + Android SDK
- Akun GNews (daftar gratis di [gnews.io](https://gnews.io), dapat 100 req/hari)

**2. Install dependencies**
```bash
flutter pub get
```

**3. Generate kode Isar** (wajib setelah clone/download)
```bash
flutter clean
dart run build_runner build --delete-conflicting-outputs
```

**4. Edit NIM kamu**
Buka `lib/core/config/env_config.dart`, ganti:
```dart
static const String nim = '2106789'; // ← ganti dengan NIM kamu
```

**5. Jalankan aplikasi**
```bash
flutter run --dart-define=GNEWS_API_KEY=api_key_kamu_disini
```

---

## Aturan NIM (Anti-Plagiasi)

Digit terakhir NIM menentukan tema secara **otomatis dan wajib**:
- **Ganjil** (1,3,5,7,9) → **Dark Mode wajib**
- **Genap** (0,2,4,6,8) → **Light Mode wajib**

Logika ini ada di `NimConfig` (`env_config.dart`) dan dipanggil di `AppTheme.requiredThemeMode` (`app_theme.dart`).

---

## Unit Test

```bash
flutter test
```

2 unit test fungsi kritikal:
1. `test/date_formatter_test.dart` — format waktu relatif (`formatTimeAgo`)
2. `test/news_article_model_test.dart` — parsing JSON GNews ke model (termasuk fallback null-safety)

---

## CI/CD GitHub Actions

Workflow `.github/workflows/build_apk.yml` otomatis jalan tiap push ke `main`:
1. Checkout + setup Java 17 + Flutter stable
2. `flutter pub get`
3. `dart run build_runner build` (generate Isar schema)
4. `flutter analyze`
5. `flutter test`
6. `flutter build apk --release`
7. Upload artifact APK ke GitHub Actions

**Setup secret GitHub** (wajib agar CI bisa build):  
`Settings → Secrets and variables → Actions → New repository secret`  
Nama: `GNEWS_API_KEY`, Value: api key GNews kamu

---

## MethodChannel — Konsep & Contoh Kode

**Apa itu MethodChannel?**  
Jembatan komunikasi dua arah antara kode Dart (Flutter) dan kode native platform
(Kotlin/Java untuk Android, Swift untuk iOS). Dipakai ketika Flutter tidak punya
API bawaan untuk fitur tertentu (sensor khusus, SDK pihak ketiga, akses hardware).

**Contoh implementasi di SkorNow (jika diaktifkan):**

Dart side (`lib/core/native/device_channel.dart`):
```dart
class DeviceChannel {
  static const _channel = MethodChannel('com.skornow/native');

  static Future<String> getDeviceInfo() async {
    return await _channel.invokeMethod('getDeviceInfo');
  }

  static Future<void> shareArticle(String title, String url) async {
    await _channel.invokeMethod('share', {'title': title, 'url': url});
  }
}
```

Kotlin side (`android/app/src/main/kotlin/.../MainActivity.kt`):
```kotlin
class MainActivity : FlutterActivity() {
  private val CHANNEL = "com.skornow/native"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "getDeviceInfo" ->
            result.success("${Build.BRAND} ${Build.MODEL} (Android ${Build.VERSION.RELEASE})")
          "share" -> {
            val intent = Intent(Intent.ACTION_SEND).apply {
              type = "text/plain"
              putExtra(Intent.EXTRA_TEXT, "${call.argument<String>("title")}\n${call.argument<String>("url")}")
            }
            startActivity(Intent.createChooser(intent, "Bagikan Berita"))
            result.success(null)
          }
          else -> result.notImplemented()
        }
      }
  }
}
```

---

## Catatan Teknis (Bug yang Diperbaiki)

- **GNews API param**: endpoint `top-headlines` pakai `category=sports` + `q=football` (bukan `topic`)
- **Isar**: pakai fork `isar_community` (bukan `isar` resmi yang sudah usang dan konflik versi Dart SDK terbaru)
- **Import isar_community**: `package:isar_community/isar.dart` (bukan `isar_community.dart`)
- **Versi lock**: ketiga paket isar dikunci versi sama persis via YAML anchor

---

## Checklist Pengumpulan UAS

- [ ] Aplikasi berjalan lancar tanpa crash di HP
- [ ] Dark Mode aktif (NIM digit terakhir ganjil)
- [ ] Breaking news ticker muncul di atas HomePage
- [ ] Artikel pertama tampil sebagai hero card (FeaturedArticleCard)
- [ ] Bookmark berfungsi (simpan + baca offline tanpa internet)
- [ ] Kode bersih dari warning (`flutter analyze`)
- [ ] Minimal 10 commits di GitHub
- [ ] APK Release ter-build otomatis via GitHub Actions CI/CD
- [ ] Link video presentasi (7 menit) disisipkan di sini: **[LINK VIDEO]**

---

*Video presentasi: 3 menit demo app (ticker, hero card, offline bookmark, dark mode, settings)  
+ 4 menit walkthrough kode (alur data UI → Cubit → Repository → Isar/Dio, Isolate compute, WebSocket service)*
