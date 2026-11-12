import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/surah_card.dart';
import '../widgets/mini_player.dart';
import 'player_sheet.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quran = context.watch<QuranProvider>();
    final player = context.watch<AudioPlayerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentOrange.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.asset(
                                  'assets/logo.png',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Goni Dahir',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'القارئ قوني طاهر إدريس • مَيْدُغُرِي',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.arabicStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Settings Button
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            size: 20,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => quran.setSearchQuery(val),
                      decoration: const InputDecoration(
                        hintText: 'Search Surah (e.g. Kahf, Yasin, 18)...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppTheme.textMuted,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter Tabs (Surahs, Downloads, Favorites)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterTab(
                          context: context,
                          label: 'Surahs (${quran.allSurahs.length})',
                          tabId: 'all',
                          isActive: quran.activeTab == 'all',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterTab(
                          context: context,
                          label: 'Downloads (${quran.downloadedCount})',
                          tabId: 'downloaded',
                          isActive: quran.activeTab == 'downloaded',
                        ),
                        const SizedBox(width: 8),
                        _buildFilterTab(
                          context: context,
                          label: 'Favorites (${quran.favoritesCount})',
                          tabId: 'fav',
                          isActive: quran.activeTab == 'fav',
                        ),
                      ],
                    ),
                  ),
                ),

                if (quran.allSurahs.any((s) => s.isDownloading))
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: const LinearProgressIndicator(
                        minHeight: 2.5,
                        backgroundColor: Color(0xFFFFEDD5),
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentOrange),
                      ),
                    ),
                  ),

                const SizedBox(height: 4),

                // Surah List
                Expanded(
                  child: quran.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentOrange,
                            ),
                          ),
                        )
                      : quran.filteredSurahs.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: AppTheme.textMuted.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No Surahs found',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.only(
                                bottom: player.hasCurrentSurah ? 90 : 20,
                              ),
                              itemCount: quran.filteredSurahs.length,
                              itemBuilder: (ctx, index) {
                                final surah = quran.filteredSurahs[index];
                                final isCurrent = player.currentSurah?.id == surah.id;

                                return SurahCard(
                                  surah: surah,
                                  isCurrent: isCurrent,
                                  onTap: () {
                                    player.playSurah(surah, quran.allSurahs);
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => const PlayerSheet(),
                                    );
                                  },
                                  onDownload: () {
                                    quran.downloadSurah(surah);
                                  },
                                  onFavorite: () {
                                    quran.toggleFavorite(surah);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),

            // Floating Mini Player
            const MiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required BuildContext context,
    required String label,
    required String tabId,
    required bool isActive,
  }) {
    final quran = context.read<QuranProvider>();

    return GestureDetector(
      onTap: () => quran.setActiveTab(tabId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? Colors.transparent : AppTheme.border,
          ),
          boxShadow: isActive
              ? [
                  const BoxShadow(
                    color: Color(0x33FF8C00),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isActive ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
