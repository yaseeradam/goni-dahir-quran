import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../providers/quran_provider.dart';
import '../theme/app_theme.dart';

class PlayerSheet extends StatelessWidget {
  const PlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<AudioPlayerProvider>();
    final quran = context.watch<QuranProvider>();
    final surah = player.currentSurah;

    if (surah == null) return const SizedBox.shrink();

    final screenHeight = MediaQuery.of(context).size.height;
    final discSize = (screenHeight * 0.26).clamp(150.0, 220.0);
    final innerDiscSize = discSize * 0.76;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.94,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Pull Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),

            // Sleek non-blocking download progress indicator line (disappears completely when downloaded)
            if (surah.isDownloading) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: surah.downloadProgress > 0 ? surah.downloadProgress : null,
                  minHeight: 2.5,
                  backgroundColor: const Color(0xFFFFEDD5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
                ),
              ),
            ] else
              const SizedBox(height: 6),

            // Scrollable Content Body to eliminate any possibility of overflow
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    // Header Row with Expanded titles to prevent horizontal clipping
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 30),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Surah ${surah.name}',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Goni Dahir Idris Maiduguri • Hafs \'an \'Asim',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top Download Action Button
                            if (surah.isDownloading)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    value: surah.downloadProgress > 0 ? surah.downloadProgress : null,
                                    strokeWidth: 2.2,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
                                  ),
                                ),
                              )
                            else if (!surah.isDownloaded)
                              IconButton(
                                icon: const Icon(Icons.download_for_offline_outlined, size: 24),
                                color: AppTheme.accentOrange,
                                tooltip: 'Download Surah (${surah.sizeMb} MB)',
                                onPressed: () => quran.downloadSurah(surah),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 20,
                                  color: Color(0xFF10B981),
                                ),
                              ),

                            // Favorite Button
                            IconButton(
                              icon: Icon(
                                surah.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: surah.isFavorite ? Colors.red : AppTheme.textSecondary,
                                size: 24,
                              ),
                              onPressed: () => quran.toggleFavorite(surah),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight < 650 ? 12 : 20),

                    // Centerpiece Glowing Disc
                    Container(
                      width: discSize,
                      height: discSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26FF3E3E),
                            blurRadius: 40,
                            spreadRadius: 3,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: innerDiscSize,
                          height: innerDiscSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Colors.white, Color(0xFFF8FAFC)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'سورة ${surah.arabic}',
                                textAlign: TextAlign.center,
                                style: AppTheme.arabicStyle(
                                  fontSize: discSize < 180 ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${surah.verses} Verses • ${surah.type}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF1F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Hafs an Asim',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight < 650 ? 12 : 20),

                    // Animated Soundwave Visualizer Bars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (index) {
                        final heights = [10.0, 18.0, 28.0, 14.0, 32.0, 22.0, 36.0, 24.0, 16.0, 30.0, 18.0, 12.0];
                        final h = player.isPlaying ? heights[index] : 8.0;
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 250 + (index * 40)),
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: 4,
                          height: h,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                    SizedBox(height: screenHeight < 650 ? 12 : 20),

                    // Progress Scrub Slider
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: AppTheme.accentOrange,
                            inactiveTrackColor: const Color(0xFFE2E8F0),
                            thumbColor: AppTheme.accentRed,
                            overlayColor: AppTheme.accentOrange.withValues(alpha: 0.15),
                          ),
                          child: Slider(
                            value: player.progressPercentage,
                            onChanged: (val) {
                              final targetMs = (val * player.duration.inMilliseconds).toInt();
                              player.seek(Duration(milliseconds: targetMs));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(player.position),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              Text(
                                _formatDuration(player.duration),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textMuted,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Secondary Quick Controls (Speed, -15s, +15s, Sleep Timer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Playback Speed Button
                        PopupMenuButton<double>(
                          initialValue: player.speed,
                          onSelected: (s) => player.setSpeed(s),
                          itemBuilder: (_) => [0.75, 1.0, 1.25, 1.5, 2.0].map((sp) {
                            return PopupMenuItem<double>(
                              value: sp,
                              child: Text('${sp}x'),
                            );
                          }).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${player.speed}x',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),

                        // Skip -15s
                        IconButton(
                          icon: const Icon(Icons.replay_10_rounded, size: 24),
                          color: AppTheme.textSecondary,
                          onPressed: () => player.seekBy(-15),
                          tooltip: 'Rewind 15 seconds',
                        ),

                        // Skip +15s
                        IconButton(
                          icon: const Icon(Icons.forward_10_rounded, size: 24),
                          color: AppTheme.textSecondary,
                          onPressed: () => player.seekBy(15),
                          tooltip: 'Forward 15 seconds',
                        ),

                        // Sleep Timer
                        PopupMenuButton<int>(
                          initialValue: player.sleepTimerMinutes,
                          onSelected: (m) => player.setSleepTimer(m),
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 0, child: Text('Timer: Off')),
                            const PopupMenuItem(value: 15, child: Text('15 minutes')),
                            const PopupMenuItem(value: 30, child: Text('30 minutes')),
                            const PopupMenuItem(value: 60, child: Text('60 minutes')),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: player.sleepTimerMinutes > 0
                                  ? const Color(0xFFFFF1F2)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: player.sleepTimerMinutes > 0
                                      ? AppTheme.accentRed
                                      : AppTheme.textSecondary,
                                ),
                                if (player.sleepTimerMinutes > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${player.sleepTimerMinutes}m',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.accentRed,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Primary Playback Controls Row (Shuffle, Previous, Play/Pause, Next, Auto-Replay)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle Toggle Button
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            size: 24,
                            color: player.isShuffle ? AppTheme.accentOrange : AppTheme.textMuted,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: player.isShuffle
                                ? const Color(0xFFFFF1F2)
                                : Colors.transparent,
                          ),
                          onPressed: () => player.toggleShuffle(),
                          tooltip: player.isShuffle
                              ? 'Shuffle: Active (Non-repeating pool)'
                              : 'Shuffle: Inactive',
                        ),

                        // Previous Surah Button
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, size: 34),
                          color: AppTheme.textPrimary,
                          onPressed: () => player.previousSurah(),
                          tooltip: 'Previous Surah',
                        ),

                        // Big Circular Red-Orange Play/Pause Button
                        GestureDetector(
                          onTap: () => player.togglePlay(),
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x4DFF3E3E),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                player.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ),

                        // Next Surah Button
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, size: 34),
                          color: AppTheme.textPrimary,
                          onPressed: () => player.nextSurah(),
                          tooltip: 'Next Surah',
                        ),

                        // Auto-Replay Toggle Button (Seamless Single-Surah Repeat for Hifz)
                        IconButton(
                          icon: Icon(
                            player.isAutoReplay
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            size: 24,
                            color: player.isAutoReplay
                                ? AppTheme.accentOrange
                                : AppTheme.textMuted,
                          ),
                          style: IconButton.styleFrom(
                            backgroundColor: player.isAutoReplay
                                ? const Color(0xFFFFF1F2)
                                : Colors.transparent,
                          ),
                          onPressed: () => player.toggleAutoReplay(),
                          tooltip: player.isAutoReplay
                              ? 'Auto-Replay: Repeating this Surah'
                              : 'Auto-Replay: Off',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final h = d.inHours.toString();
      return '$h:$m:$s';
    }
    return '$m:$s';
  }
}
