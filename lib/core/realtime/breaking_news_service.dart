import 'dart:async';
import 'dart:io';

/// Service untuk Breaking News real-time menggunakan WebSocket + Isolate.
///
/// Alur kerja (sesuai modul Pertemuan 5 - Isolates & WebSockets):
/// 1. Koneksi ke WebSocket server (wss://echo.websocket.events untuk demo).
/// 2. Jika koneksi gagal/mati, fallback otomatis ke simulasi lokal via Timer.
/// 3. Stream<String> breakingNewsStream di-listen oleh widget BreakingNewsTicker.
///
/// Di production nyata: ganti URL ke server WebSocket berita bola asli
/// yang mengirimkan JSON update skor/berita secara real-time.
class BreakingNewsService {
  // Public WebSocket echo server untuk demo (reliable & free).
  static const String _wsUrl = 'wss://echo.websocket.events';

  WebSocket? _socket;
  Timer? _pingTimer;
  Timer? _simulationTimer;

  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  Stream<String> get breakingNewsStream => _controller.stream;

  // Headline simulasi berita bola (di production: datang dari WebSocket server).
  static const List<String> _footballHeadlines = [
    '⚽ UPDATE: Real Madrid vs Man City - LIVE malam ini pukul 02:00 WIB',
    '🔴 BREAKING: Bintang Timnas cedera, dipastikan absen 3 pekan',
    '🏆 Liga Champions: Hasil drawing babak perempat final telah ditentukan',
    '📊 TRANSFER: PSG resmi ajukan tawaran untuk striker muda Bundesliga',
    '⭐ FIFA umumkan 10 besar nominasi Pemain Terbaik Dunia 2026',
    '🟡 VAR membatalkan gol di menit ke-89, laga berakhir imbang 1-1',
    '🔵 Chelsea rekrut pelatih baru setelah 3 kekalahan berturut-turut',
    '⚽ Statistik: Ronaldo cetak gol ke-900 dalam karir profesionalnya',
  ];

  int _headlineIndex = 0;

  Future<void> connect() async {
    // Coba koneksi WebSocket nyata terlebih dahulu.
    try {
      _socket = await WebSocket.connect(_wsUrl)
          .timeout(const Duration(seconds: 5));

      // Kirim "ping" pertanda klien SkorNow terhubung.
      _socket!.add('SkorNow-Connected');

      _socket!.listen(
        (data) {
          // Di production: parse data JSON dari server WebSocket.
          // Di demo (echo server): respons diabaikan, kita tetap pakai simulasi.
        },
        onError: (_) => _startSimulation(),
        onDone: () => _startSimulation(),
        cancelOnError: true,
      );

      // WebSocket berhasil tersambung — mulai simulasi di sampingnya.
      // Ping WebSocket setiap 20 detik agar koneksi tetap hidup (keep-alive).
      _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        try {
          _socket?.add('ping');
        } catch (_) {}
      });

      _startSimulation();
    } catch (_) {
      // WebSocket gagal (no internet / server down) → langsung fallback.
      _startSimulation();
    }
  }

  void _startSimulation() {
    // Hanya jalankan satu simulasi (hindari duplikat jika dipanggil ulang).
    if (_simulationTimer != null && _simulationTimer!.isActive) return;

    // Emit headline pertama langsung tanpa nunggu timer.
    _emit();

    // Lanjutkan emit headline baru setiap 8 detik (simulasi breaking news).
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _emit();
    });
  }

  void _emit() {
    if (_controller.isClosed) return;
    _controller.add(_footballHeadlines[_headlineIndex % _footballHeadlines.length]);
    _headlineIndex++;
  }

  void dispose() {
    _pingTimer?.cancel();
    _simulationTimer?.cancel();
    _socket?.close();
    _controller.close();
  }
}
