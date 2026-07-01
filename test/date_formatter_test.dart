import 'package:flutter_test/flutter_test.dart';
import 'package:skornow/core/utils/date_formatter.dart';

void main() {
  group('formatTimeAgo', () {
    test('mengembalikan "Baru saja" jika kurang dari 1 menit', () {
      final now = DateTime(2026, 6, 30, 12, 0, 0);
      final published = now.subtract(const Duration(seconds: 30));

      expect(formatTimeAgo(published, now: now), 'Baru saja');
    });

    test('mengembalikan format menit jika kurang dari 1 jam', () {
      final now = DateTime(2026, 6, 30, 12, 0, 0);
      final published = now.subtract(const Duration(minutes: 15));

      expect(formatTimeAgo(published, now: now), '15 menit lalu');
    });

    test('mengembalikan format jam jika kurang dari 24 jam', () {
      final now = DateTime(2026, 6, 30, 12, 0, 0);
      final published = now.subtract(const Duration(hours: 3));

      expect(formatTimeAgo(published, now: now), '3 jam lalu');
    });

    test('mengembalikan format hari jika kurang dari 7 hari', () {
      final now = DateTime(2026, 6, 30, 12, 0, 0);
      final published = now.subtract(const Duration(days: 2));

      expect(formatTimeAgo(published, now: now), '2 hari lalu');
    });

    test('mengembalikan format minggu jika kurang dari 30 hari', () {
      final now = DateTime(2026, 6, 30, 12, 0, 0);
      final published = now.subtract(const Duration(days: 10));

      expect(formatTimeAgo(published, now: now), '1 minggu lalu');
    });
  });
}
