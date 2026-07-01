/// Konfigurasi Environment (DEV/PROD) untuk SkorNow.
///
/// Cara override saat build:
/// flutter run --dart-define=ENV_NAME=PROD --dart-define=GNEWS_API_KEY=xxxxx
class EnvConfig {
  EnvConfig._();

  static const String environment = String.fromEnvironment(
    'ENV_NAME',
    defaultValue: 'DEV',
  );

  /// Base URL GNews API.
  /// Daftar dulu di https://gnews.io untuk mendapatkan API Key gratis
  /// (free tier: 100 request/hari, tanpa kartu kredit).
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://gnews.io/api/v4',
  );

  /// WAJIB diisi sendiri saat build/run, jangan commit API Key asli ke GitHub.
  /// flutter run --dart-define=GNEWS_API_KEY=isi_api_key_kamu
  static const String gnewsApiKey = String.fromEnvironment(
    'GNEWS_API_KEY',
    defaultValue: 'PASTE_API_KEY_KAMU_DISINI',
  );

  /// Kategori & kata kunci berita yang difetch.
  /// Endpoint resmi GNews (top-headlines) TIDAK punya parameter "topic" --
  /// yang ada adalah "category" (general/world/nation/business/technology/
  /// entertainment/sports/science/health) dikombinasikan dengan "q" (keyword).
  /// Lihat: https://docs.gnews.io/endpoints/top-headlines-endpoint
  static const String newsCategory = 'sports';
  static const String newsQuery = 'football';
  static const String newsLang = 'id';

  static bool get isProduction => environment == 'PROD';
}

/// Aturan Anti-Plagiasi (Data Dinamis berdasarkan NIM):
/// Jika digit terakhir NIM ganjil -> tema WAJIB Dark Mode.
/// Jika digit terakhir NIM genap -> tema WAJIB Light Mode.
///
/// NIM contoh berakhiran 9 (ganjil) -> Dark Mode wajib aktif.
class NimConfig {
  NimConfig._();

  /// Ganti dengan NIM kamu sendiri.
  static const String nim = '2106789';

  static int get lastDigit => int.parse(nim.substring(nim.length - 1));

  static bool get isOddNim => lastDigit % 2 != 0;

  /// true = Dark Mode wajib, false = Light Mode wajib.
  static bool get isDarkModeRequired => isOddNim;
}

