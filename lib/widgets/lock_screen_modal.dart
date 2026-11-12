import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';

class LockScreenModal extends StatelessWidget {
  const LockScreenModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LockScreenModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerProvider>();
    final currentSurah = player.currentSurah;
    final isEnabled = player.lockScreenControls;

    final surahTitle = currentSurah != null ? 'Surah ${currentSurah.name}' : 'Surah Al-Kahf';
    final surahArabic = currentSurah != null ? currentSurah.arabic : 'الكهف';

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Handle Bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.screen_lock_portrait_rounded,
                            color: AppTheme.accentRed,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lock Screen Playback',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Background & Notification Controls',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppTheme.border),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Quick Toggle Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isEnabled ? AppTheme.primaryGradient : null,
                      color: isEnabled ? null : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isEnabled ? Colors.transparent : AppTheme.border,
                      ),
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                color: AppTheme.accentOrange.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnabled
                                    ? 'Lock Screen Controls: ACTIVE'
                                    : 'Lock Screen Controls: DISABLED',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isEnabled ? Colors.white : AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isEnabled
                                    ? 'Recitation media controls appear on your lock screen & notification shade.'
                                    : 'Tap switch to enable seamless lock screen and notification media controls.',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isEnabled
                                      ? Colors.white.withValues(alpha: 0.9)
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: Colors.white.withValues(alpha: 0.4),
                          inactiveThumbColor: AppTheme.textMuted,
                          inactiveTrackColor: Colors.grey.shade300,
                          onChanged: (val) {
                            player.toggleLockScreenControls(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Phone Lock Screen Mockup Preview
                  const Text(
                    'LOCK SCREEN PREVIEW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A), // Deep AMOLED night style
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Status Bar Mockup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '10:45',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.lock_rounded, size: 12, color: Colors.white70),
                                const SizedBox(width: 8),
                                Icon(
                                  isEnabled ? Icons.music_note_rounded : Icons.music_off_rounded,
                                  size: 13,
                                  color: isEnabled ? AppTheme.accentOrange : Colors.white38,
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.wifi_rounded, size: 12, color: Colors.white70),
                                const SizedBox(width: 6),
                                const Icon(Icons.battery_full_rounded, size: 14, color: Colors.white70),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Notification Card Mockup
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Album Art
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentOrange.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        'assets/logo.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$surahTitle ($surahArabic)',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Goni Dahir Idris Maiduguri • Hafs \'an \'Asim',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentOrange.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'QURAN',
                                      style: TextStyle(
                                        color: AppTheme.accentOrange,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Progress Line Mockup
                              LinearProgressIndicator(
                                value: player.progressPercentage > 0 ? player.progressPercentage : 0.45,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation(AppTheme.accentOrange),
                                minHeight: 3,
                              ),

                              const SizedBox(height: 8),

                              // Lock Screen Control Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous_rounded, size: 26),
                                    color: Colors.white70,
                                    onPressed: () => player.previousSurah(),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.replay_10_rounded, size: 22),
                                    color: Colors.white70,
                                    onPressed: () => player.seekBy(-10),
                                  ),
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: AppTheme.primaryGradient,
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: Icon(
                                        player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        size: 24,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => player.togglePlay(),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.forward_10_rounded, size: 22),
                                    color: Colors.white70,
                                    onPressed: () => player.seekBy(10),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next_rounded, size: 26),
                                    color: Colors.white70,
                                    onPressed: () => player.nextSurah(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Feature Guidance Cards
                  _buildGuidanceCard(
                    icon: Icons.notifications_active_outlined,
                    iconColor: AppTheme.accentOrange,
                    title: 'System Notification Priority',
                    description:
                        'The media notification is prioritized by Android MediaSession so you can control recitation without waking the full screen.',
                  ),

                  const SizedBox(height: 12),

                  _buildGuidanceCard(
                    icon: Icons.battery_charging_full_rounded,
                    iconColor: const Color(0xFF10B981),
                    title: 'Battery Optimization Guidance',
                    description:
                        'To prevent Android battery savers from pausing long Surahs (such as Al-Baqarah 60MB), ensure "Battery" is set to "Unrestricted" in App Info settings.',
                  ),

                  const SizedBox(height: 12),

                  _buildGuidanceCard(
                    icon: Icons.headset_rounded,
                    iconColor: AppTheme.accentRed,
                    title: 'Headphone & Bluetooth Auto-Pause',
                    description:
                        'Recitation automatically pauses safely whenever Bluetooth headphones or wired earphones disconnect.',
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
