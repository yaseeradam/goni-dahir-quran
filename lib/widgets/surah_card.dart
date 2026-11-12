import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../theme/app_theme.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onDownload;
  final VoidCallback onFavorite;

  const SurahCard({
    super.key,
    required this.surah,
    required this.isCurrent,
    required this.onTap,
    required this.onDownload,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrent ? AppTheme.accentOrange.withValues(alpha: 0.5) : AppTheme.border,
          width: isCurrent ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? AppTheme.accentOrange.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      // Circular Surah Number Badge
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? AppTheme.accentOrange.withValues(alpha: 0.12)
                              : const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: isCurrent
                                ? AppTheme.accentOrange
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${surah.id}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isCurrent
                                  ? AppTheme.accentRed
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),

                const SizedBox(width: 14),

                // Name & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              surah.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isCurrent
                                    ? AppTheme.accentRed
                                    : AppTheme.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          // Offline Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: surah.isDownloaded
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              surah.isDownloaded ? 'Offline' : 'Online',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: surah.isDownloaded
                                    ? const Color(0xFF059669)
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${surah.verses} Verses • ${surah.type} • ${surah.sizeMb} MB',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arabic Name Calligraphy
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    surah.arabic,
                    style: AppTheme.arabicStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isCurrent
                          ? AppTheme.accentRed
                          : AppTheme.textPrimary,
                    ),
                  ),
                ),

                // Action Download / Status Button
                _buildActionButton(),
                    ],
                  ),
                ),
              ),
            ),
            // Non-blocking Left-to-Right download progress line
            if (surah.isDownloading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LinearProgressIndicator(
              value: surah.downloadProgress > 0 ? surah.downloadProgress : null,
              minHeight: 3.5,
              backgroundColor: const Color(0xFFFFEDD5),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
            ),
          ),
      ],
    ),
  ),
);
}

  Widget _buildActionButton() {
    if (surah.isDownloading) {
      final pct = (surah.downloadProgress * 100).toInt();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFED7AA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$pct%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppTheme.accentOrange,
              ),
            ),
          ],
        ),
      );
    }

    if (surah.isDownloaded) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          size: 18,
          color: Color(0xFF10B981),
        ),
      );
    }

    // Download Button with Red-Orange Gradient
    return GestureDetector(
      onTap: onDownload,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: Color(0x33FF8C00),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_downward_rounded,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }
}
