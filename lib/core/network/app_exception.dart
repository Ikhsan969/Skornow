/// Exception kustom supaya error dari Dio bisa ditampilkan
/// dengan pesan yang ramah pengguna di UI (Aturan 3: Fail-Safe UI).
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkFailureException extends AppException {
  NetworkFailureException()
      : super('Tidak ada koneksi internet. Menampilkan data tersimpan.');
}

class ServerFailureException extends AppException {
  ServerFailureException([String? detail])
      : super(detail ?? 'Server sedang bermasalah, coba lagi nanti.');
}
