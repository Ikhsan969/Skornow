import 'package:flutter/material.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('Pengaturan ⚙️')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tentang Aplikasi
          _SectionHeader('Tentang Aplikasi'),
          _InfoTile(
            icon: Icons.sports_soccer,
            iconColor: AppColors.primary,
            title: 'SkorNow',
            subtitle: 'Portal Berita Bola Offline-First\nFinal Project UAS Mobile Programming Lanjut',
          ),
          const SizedBox(height: 16),

          // Environment
          _SectionHeader('Informasi Environment'),
          _InfoTile(
            icon: Icons.dns_outlined,
            iconColor: AppColors.accent,
            title: 'Environment',
            subtitle: EnvConfig.environment,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: EnvConfig.isProduction
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                EnvConfig.isProduction ? 'PROD' : 'DEV',
                style: TextStyle(
                  color: EnvConfig.isProduction ? AppColors.primary : Colors.orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          _InfoTile(
            icon: Icons.link_rounded,
            iconColor: AppColors.textSecondary,
            title: 'Base URL API',
            subtitle: EnvConfig.baseUrl,
          ),
          const SizedBox(height: 16),

          // Tema NIM
          _SectionHeader('Tema (Aturan NIM Anti-Plagiasi)'),
          _InfoTile(
            icon: NimConfig.isDarkModeRequired ? Icons.dark_mode : Icons.light_mode,
            iconColor: AppColors.accent,
            title: NimConfig.isDarkModeRequired ? 'Dark Mode (Wajib Aktif)' : 'Light Mode (Wajib Aktif)',
            subtitle: 'Digit terakhir NIM: ${NimConfig.lastDigit} (${NimConfig.isOddNim ? 'Ganjil → Dark Mode' : 'Genap → Light Mode'})',
          ),
          const SizedBox(height: 16),

          // Arsitektur
          _SectionHeader('Arsitektur & Teknologi'),
          _TechTile(icon: Icons.layers_rounded, color: Colors.blue, label: 'Clean Architecture + GetIt DI'),
          _TechTile(icon: Icons.route_rounded, color: Colors.purple, label: 'go_router (navigasi)'),
          _TechTile(icon: Icons.sync_rounded, color: AppColors.primary, label: 'BLoC/Cubit (state management)'),
          _TechTile(icon: Icons.storage_rounded, color: Colors.orange, label: 'Isar — Offline-First Database'),
          _TechTile(icon: Icons.network_check_rounded, color: Colors.teal, label: 'Dio Interceptors (network)'),
          _TechTile(icon: Icons.wifi_rounded, color: AppColors.red, label: 'WebSocket — Breaking News Real-time'),
          _TechTile(icon: Icons.memory_rounded, color: Colors.amber, label: 'Isolates — compute() background parsing'),
          _TechTile(icon: Icons.animation_rounded, color: Colors.pink, label: 'Lottie — error & loading animation'),
          const SizedBox(height: 16),

          // MethodChannel explanation
          _SectionHeader('MethodChannel (Native Bridge)'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.code_rounded, color: AppColors.accent, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Konsep MethodChannel',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'MethodChannel adalah jembatan antara kode Flutter (Dart) dan kode native platform (Kotlin/Java untuk Android, Swift untuk iOS).\n\n'
                  'Contoh penggunaan di SkorNow:\n'
                  '• Membaca info perangkat (brand, model, versi OS)\n'
                  '• Memicu native share sheet untuk berbagi berita\n'
                  '• Mengakses sensor hardware (baterai, GPS) langsung dari platform\n\n'
                  'Kode Dart:\n'
                  'static const _channel = MethodChannel("com.skornow/native");\n'
                  'final info = await _channel.invokeMethod("getDeviceInfo");\n\n'
                  'Kode Kotlin (MainActivity.kt):\n'
                  'channel.setMethodCallHandler { call, result ->\n'
                  '  if (call.method == "getDeviceInfo")\n'
                  '    result.success("\${Build.BRAND} \${Build.MODEL}")\n'
                  '}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.6,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _TechTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _TechTile({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDark, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
