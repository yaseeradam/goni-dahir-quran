import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../providers/quran_provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/lock_screen_modal.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTestingPing = false;
  int? _pingLatencyMs;
  String? _pingStatus;

  bool _isValidatingCache = false;
  String? _cacheIntegrityReport;

  Future<void> _testCdnPing() async {
    setState(() {
      _isTestingPing = true;
      _pingStatus = 'Pinging CDN endpoint...';
      _pingLatencyMs = null;
    });

    final stopwatch = Stopwatch()..start();
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final response = await dio.head('https://quran.academyhub.com.ng/surahs.json');
      stopwatch.stop();

      if (mounted) {
        setState(() {
          _isTestingPing = false;
          _pingLatencyMs = stopwatch.elapsedMilliseconds;
          if (response.statusCode == 200) {
            _pingStatus = 'Online • Optimal response';
          } else {
            _pingStatus = 'Server replied with status ${response.statusCode}';
          }
        });
      }
    } catch (e) {
      stopwatch.stop();
      if (mounted) {
        setState(() {
          _isTestingPing = false;
          _pingLatencyMs = stopwatch.elapsedMilliseconds;
          _pingStatus = 'CDN unreachable or network offline';
        });
      }
    }
  }

  Future<void> _validateCacheIntegrity(QuranProvider quran) async {
    setState(() {
      _isValidatingCache = true;
      _cacheIntegrityReport = 'Scanning local audio cache...';
    });

    try {
      final dirPath = await quran.downloadService.getAudioDirectory();
      final dir = Directory(dirPath);
      int validFiles = 0;
      int corruptedRemoved = 0;

      if (await dir.exists()) {
        await for (final file in dir.list(recursive: false)) {
          if (file is File && file.path.endsWith('.mp3')) {
            final len = await file.length();
            if (len < 50000) {
              // Corrupt 0-byte or incomplete download
              await file.delete();
              corruptedRemoved++;
            } else {
              validFiles++;
            }
          }
        }
      }

      await quran.downloadService.pruneTempFiles();
      await quran.initialize();

      if (mounted) {
        setState(() {
          _isValidatingCache = false;
          _cacheIntegrityReport =
              '$validFiles valid audio files verified. '
              '${corruptedRemoved > 0 ? "$corruptedRemoved damaged files cleaned." : "No corrupt files detected."}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidatingCache = false;
          _cacheIntegrityReport = 'Cache validation encountered an error.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quran = context.watch<QuranProvider>();
    final player = context.watch<AudioPlayerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Settings & Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppTheme.textPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          // ==========================================
          // 1. RECITER & RIWAYAH PROFILE
          // ==========================================
          _buildSectionHeader('Reciter & Riwayah Profile'),
          _buildReciterProfileCard(),

          const SizedBox(height: 20),

          // ==========================================
          // 2. AUDIO PLAYBACK PREFERENCES
          // ==========================================
          _buildSectionHeader('Audio Playback Preferences'),
          _buildPlaybackPreferencesCard(player),

          const SizedBox(height: 20),

          // ==========================================
          // 3. STORAGE & OFFLINE MANAGEMENT
          // ==========================================
          _buildSectionHeader('Storage & Offline Management'),
          _buildStorageManagementCard(quran),

          const SizedBox(height: 20),

          // ==========================================
          // 4. APP & CDN DIAGNOSTICS
          // ==========================================
          _buildSectionHeader('CDN & Network Diagnostics'),
          _buildDiagnosticsCard(quran),

          const SizedBox(height: 20),

          // ==========================================
          // 5. ABOUT US (FRONTALMINDS AGENCY)
          // ==========================================
          _buildSectionHeader('About Us • FrontalMinds Agency'),
          _buildAboutUsCard(),

          const SizedBox(height: 30),

          // Footer version info
          const Center(
            child: Column(
              children: [
                Text(
                  'Goni Dahir Quran App • Version 1.0.0+1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Murattal Recitation in Hafs an Asim',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  // 1. Reciter Profile Card
  Widget _buildReciterProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/logo.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Goni Dahir Idris Maiduguri',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'القارئ قوني طاهر إدريس مَيْدُغُرِي',
                      style: AppTheme.arabicStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),
          _buildProfileDetailRow(
            icon: Icons.location_on_rounded,
            label: 'Origin & Tradition',
            value: 'Maiduguri, Borno State • Goni Tradition',
            highlightColor: AppTheme.accentOrange,
          ),
          const SizedBox(height: 10),
          _buildProfileDetailRow(
            icon: Icons.auto_stories_rounded,
            label: 'Canonical Riwayah',
            value: 'Hafs \'an \'Asim (حفص عن عاصم)',
            highlightColor: AppTheme.accentRed,
          ),
          const SizedBox(height: 10),
          _buildProfileDetailRow(
            icon: Icons.mic_external_on_rounded,
            label: 'Recitation Style',
            value: 'Murattal Tajweed (مرتّل)',
          ),
          const SizedBox(height: 10),
          _buildProfileDetailRow(
            icon: Icons.library_music_rounded,
            label: 'Catalog Availability',
            value: '60 Recorded Surahs (Catalog Complete)',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Text(
              'Goni Dahir Idris Maiduguri is a celebrated Quranic reciter from Maiduguri, Borno State, renowned for his distinct and melodic Borno recitation cadence adhering strictly to the Shatibiyyah transmission of Hafs an Asim. In the Borno tradition, "Goni" represents the highest honor for complete Quranic memorization and mastery.',
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? highlightColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 17, color: AppTheme.accentOrange),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: highlightColor ?? AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // 2. Playback Preferences Card
  Widget _buildPlaybackPreferencesCard(AudioPlayerProvider player) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Playback Speed Selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Playback Speed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Adjust recitation pacing',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      '${player.speed}x Normal',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [0.75, 1.0, 1.25, 1.5].map((s) {
                  final isSelected = (player.speed - s).abs() < 0.05;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => player.setSpeed(s),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.accentOrange : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppTheme.accentOrange : const Color(0xFFE2E8F0),
                                width: 1.2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${s}x',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Auto-Replay (Hifz Memorization Mode)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-Replay Surah (Hifz Mode)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Seamlessly repeat the current Surah for memorization',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: player.isAutoReplay,
                activeThumbColor: AppTheme.accentOrange,
                onChanged: (_) => player.toggleAutoReplay(),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Shuffle Mode
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shuffle Recitations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Plays non-repeating cycle across the 60 Surahs',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: player.isShuffle,
                activeThumbColor: AppTheme.accentOrange,
                onChanged: (_) => player.toggleShuffle(),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Lock Screen Playback Controls & Preview Modal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'Lock Screen Playback',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.screen_lock_portrait_rounded,
                          size: 16,
                          color: AppTheme.accentOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      player.lockScreenControls
                          ? 'Controls active on lock screen & notifications'
                          : 'Disabled (Tap configure to activate)',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => LockScreenModal.show(context),
                icon: const Icon(Icons.tune_rounded, size: 15),
                label: const Text(
                  'Preview',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentOrange,
                  side: const BorderSide(color: AppTheme.accentOrange, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Audio Focus & Headphone Behavior Note
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.headset_rounded, size: 16, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Audio Session handles interruptions: pauses on unplug or phone call.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Storage Management Card
  Widget _buildStorageManagementCard(QuranProvider quran) {
    final downloaded = quran.downloadedCount;
    final total = quran.allSurahs.length;
    final progress = total > 0 ? (downloaded / total).clamp(0.0, 1.0) : 0.0;
    final cacheMb = quran.cachedSizeMb.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Downloaded Audio Cache',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$downloaded of $total Surahs offline',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$cacheMb MB',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.accentOrange,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Wi-Fi Only Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Download Only on Wi-Fi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Prevents mobile data consumption',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: quran.wifiOnly,
                activeThumbColor: AppTheme.accentOrange,
                onChanged: (val) => quran.toggleWifiOnly(val),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Download All / Clear Cache
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    quran.downloadAllSurahs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Downloading all Surahs in background...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_for_offline_rounded, size: 16),
                  label: const Text('Download All'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.accentOrange,
                    side: const BorderSide(color: AppTheme.accentOrange),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              if (downloaded > 0) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmClearCache(context, quran),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Clear Cache'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 4. CDN & Diagnostics Card
  Widget _buildDiagnosticsCard(QuranProvider quran) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CDN Endpoint Latency',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'quran.academyhub.com.ng',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _isTestingPing ? null : _testCdnPing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isTestingPing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Ping CDN',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
          if (_pingStatus != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Icon(
                    _pingLatencyMs != null && _pingLatencyMs! < 1000
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    size: 16,
                    color: _pingLatencyMs != null && _pingLatencyMs! < 1000
                        ? const Color(0xFF10B981)
                        : AppTheme.accentOrange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pingLatencyMs != null
                          ? '$_pingStatus (${_pingLatencyMs}ms)'
                          : _pingStatus!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Storage Integrity Check
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Storage Integrity Check',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Detects & purges damaged files',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: _isValidatingCache
                    ? null
                    : () => _validateCacheIntegrity(quran),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: AppTheme.textPrimary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isValidatingCache
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Validate',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      ),
              ),
            ],
          ),
          if (_cacheIntegrityReport != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                _cacheIntegrityReport!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _confirmClearCache(BuildContext context, QuranProvider quran) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Downloaded Audio?'),
        content: const Text(
          'This will remove all offline recitation files from your device. You can re-download them anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              quran.clearAllCache();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All downloaded audio has been cleared.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 5. About Us Card (Data from https://frontalminds.com.ng/)
  Widget _buildAboutUsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Agency Badge
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'FM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'FrontalMinds',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Color(0xFF10B981),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Digital Solutions Agency • Web & Mobile',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Agency Description
          const Text(
            'We are a boutique software studio engineering fast web systems, native applications, and secure backend solutions for companies looking to scale. Award-winning digital agency crafting beautiful, functional, and scalable digital solutions for forward-thinking brands.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Key Stats Grid (150+ Projects, 98% Satisfaction, 12+ Years, 24/7 Support)
          Row(
            children: [
              Expanded(child: _buildStatBox('150+', 'Projects\nDelivered')),
              const SizedBox(width: 6),
              Expanded(child: _buildStatBox('98%', 'Client\nSatisfaction')),
              const SizedBox(width: 6),
              Expanded(child: _buildStatBox('12+', 'Years\nExperience')),
              const SizedBox(width: 6),
              Expanded(child: _buildStatBox('24/7', 'Support\nSystem')),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Capabilities & Specializations
          const Text(
            'CORE CAPABILITIES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildCapabilityRow(
            icon: Icons.language_rounded,
            title: 'Web Engineering',
            desc: 'Ultra-fast web systems with React, Next.js, and TypeScript.',
          ),
          const SizedBox(height: 8),
          _buildCapabilityRow(
            icon: Icons.phone_iphone_rounded,
            title: 'Native Applications',
            desc: 'iOS and Android products designed for retention and performance.',
          ),
          const SizedBox(height: 8),
          _buildCapabilityRow(
            icon: Icons.cloud_done_rounded,
            title: 'Cloud & Systems Architecture',
            desc: 'Secure backend architectures with bank-grade security protocols.',
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 14),

          // Office Location & Contact
          const Text(
            'OFFICE & CONTACT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),

          _buildContactInfoRow(
            icon: Icons.location_on_outlined,
            text: '34 Zoo Road, Kano, Kano State, Nigeria, 700002',
          ),
          const SizedBox(height: 6),
          _buildContactInfoRow(
            icon: Icons.mail_outline_rounded,
            text: 'princeykarg@gmail.com',
          ),
          const SizedBox(height: 6),
          _buildContactInfoRow(
            icon: Icons.phone_outlined,
            text: '+234 810 482 7838',
          ),
          const SizedBox(height: 6),
          _buildContactInfoRow(
            icon: Icons.public_rounded,
            text: 'https://frontalminds.com.ng/',
          ),

          const SizedBox(height: 14),

          // Islamic Contribution Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Engineered with reverence as a continuous Sadaqah Jariyah for Goni Dahir Idris Maiduguri Quranic recitations.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppTheme.accentOrange,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapabilityRow({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.accentOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.accentOrange, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppTheme.accentRed),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
