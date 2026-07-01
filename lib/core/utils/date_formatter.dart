/// Fungsi murni (pure function) untuk memformat waktu publish artikel
/// menjadi format relatif seperti "2 jam lalu", "Baru saja", dsb.
///
/// Sengaja dibuat sebagai pure function (tidak bergantung pada Isar/Dio/UI)
/// supaya mudah di-unit-test sesuai syarat UAS poin 6.
String formatTimeAgo(DateTime publishedAt, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  final difference = currentTime.difference(publishedAt);

  if (difference.isNegative) {
    return 'Baru saja';
  }
  if (difference.inSeconds < 60) {
    return 'Baru saja';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit lalu';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours} jam lalu';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} hari lalu';
  }
  if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks minggu lalu';
  }
  if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months bulan lalu';
  }
  final years = (difference.inDays / 365).floor();
  return '$years tahun lalu';
}
