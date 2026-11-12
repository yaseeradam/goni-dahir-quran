import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../services/download_service.dart';

class QuranProvider extends ChangeNotifier {
  final DownloadService _downloadService = DownloadService();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  List<Surah> _allSurahs = [];
  String _searchQuery = '';
  String _activeTab = 'all'; // 'all', 'downloaded', 'fav'
  bool _wifiOnly = true;
  int _cachedSizeBytes = 0;
  bool _isLoading = true;

  List<Surah> get allSurahs => _allSurahs;
  String get searchQuery => _searchQuery;
  String get activeTab => _activeTab;
  bool get wifiOnly => _wifiOnly;
  int get cachedSizeBytes => _cachedSizeBytes;
  double get cachedSizeMb => _cachedSizeBytes / (1024 * 1024);
  bool get isLoading => _isLoading;
  DownloadService get downloadService => _downloadService;

  List<Surah> get filteredSurahs {
    final rawQuery = _searchQuery.trim();
    if (rawQuery.isEmpty) {
      return _filterByTab(_allSurahs);
    }

    final queryLower = rawQuery.toLowerCase();
    final latinQuery = _normalizeLatin(rawQuery);
    final arabicQuery = _normalizeArabic(rawQuery);
    final int? numberQuery = int.tryParse(rawQuery);
    final int? aliasSurahId = _hausaAliases[latinQuery] ?? _hausaAliases[queryLower];

    return _filterByTab(_allSurahs.where((s) {
      // 1. Number match (handles 1, 01, 001)
      if (numberQuery != null && s.id == numberQuery) {
        return true;
      }

      // 2. Hausa vernacular alias match
      if (aliasSurahId != null && s.id == aliasSurahId) {
        return true;
      }

      // 3. Latin name match
      if (s.name.toLowerCase().contains(queryLower) ||
          _normalizeLatin(s.name).contains(latinQuery)) {
        return true;
      }

      // 4. Arabic name match with full diacritic & letter normalization
      if (arabicQuery.isNotEmpty && _normalizeArabic(s.arabic).contains(arabicQuery)) {
        return true;
      }

      return false;
    }).toList());
  }

  List<Surah> _filterByTab(List<Surah> surahs) {
    if (_activeTab == 'downloaded') {
      return surahs.where((s) => s.isDownloaded).toList();
    }
    if (_activeTab == 'fav') {
      return surahs.where((s) => s.isFavorite).toList();
    }
    return surahs;
  }

  int get downloadedCount => _allSurahs.where((s) => s.isDownloaded).length;
  int get favoritesCount => _allSurahs.where((s) => s.isFavorite).length;

  static String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '') // diacritics & Quranic signs
        .replaceAll(RegExp(r'[إأآاٱ]'), 'ا') // unify alef and alef waslah
        .replaceAll(RegExp(r'[ؤئء]'), 'ء') // unify hamzas
        .replaceAll('ـ', '') // tatweel
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .trim();
  }

  static String _normalizeLatin(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r"['`‘’\-_ ]"), '')
        .replaceAll('ɓ', 'b')
        .replaceAll('ɗ', 'd')
        .replaceAll('ƙ', 'k')
        .replaceAll('q', 'k')
        .replaceAll('ts', 's')
        .replaceAll('c', 'ch')
        .trim();
  }

  static final Map<String, int> _hausaAliases = {
    'fatiha': 1, 'fatihah': 1,
    'bakara': 2, 'baqara': 2, 'baqarah': 2,
    'imran': 3, 'ali imran': 3,
    'nisa': 4, 'nisa-i': 4,
    'maida': 5, 'maidah': 5,
    'anam': 6, 'an am': 6, 'an\'am': 6,
    'araf': 7, 'a\'araf': 7,
    'anfal': 8,
    'tauba': 9, 'taubah': 9, 'bara\'a': 9, 'baraa': 9,
    'yunus': 10,
    'hud': 11,
    'yusuf': 12,
    'raad': 13, 'ra\'ad': 13,
    'ibrahim': 14,
    'hijr': 15,
    'nahl': 16, 'nahli': 16,
    'isra': 17, 'isra\'i': 17, 'bani israil': 17,
    'kahf': 18, 'kahfi': 18,
    'maryam': 19,
    'daha': 20, 'taha': 20,
    'anbiya': 21,
    'hajj': 22, 'hajji': 22,
    'muminun': 23, 'mu\'minun': 23,
    'nur': 24, 'nuri': 24,
    'furqan': 25, 'furkan': 25,
    'shuara': 26, 'shu\'ara': 26,
    'naml': 27, 'namli': 27,
    'qasas': 28, 'kasas': 28,
    'ankabut': 29,
    'rum': 30,
    'luqman': 31, 'lukman': 31,
    'sajadah': 32, 'sajada': 32,
    'ahzab': 33,
    'saba': 34,
    'fatir': 35, 'fadir': 35,
    'yasin': 36,
    'saffat': 37,
    'sad': 38,
    'zumar': 39,
    'ghafir': 40, 'gafir': 40, 'mumin': 40,
    'fussilat': 41,
    'shura': 42,
    'zuhruf': 43,
    'dukhan': 44,
    'jathiyah': 45, 'jasiya': 45,
    'ahqaf': 46, 'ahkaf': 46,
    'muhammad': 47,
    'fath': 48, 'fathi': 48,
    'hujurat': 49,
    'qaf': 50, 'kaf': 50,
    'zariyat': 51,
    'tur': 52, 'dur': 52,
    'najm': 53, 'najmi': 53,
    'qamar': 54, 'kamar': 54,
    'rahman': 55,
    'waqiah': 56, 'waqi\'ah': 56, 'wakiya': 56,
    'hadid': 57,
    'mujadalah': 58, 'mujadala': 58,
    'hashr': 59, 'hashri': 59,
    'mumtahanah': 60, 'mumtahana': 60,
    'saff': 61,
    'jumuah': 62, 'jumu\'ah': 62, 'juma': 62,
    'munafiqun': 63, 'munafikun': 63,
    'taghabun': 64, 'tagabun': 64,
    'talaq': 65, 'dalak': 65,
    'tahrim': 66,
    'mulk': 67, 'mulku': 67, 'tabarak': 67,
    'qalam': 68, 'kalam': 68, 'nun': 68,
    'haqqah': 69, 'hakka': 69,
    'maarij': 70, 'ma\'arij': 70,
    'nuh': 71, 'nuhu': 71,
    'jinn': 72, 'jinni': 72,
    'muzzammil': 73,
    'muddathir': 74, 'muddassir': 74,
    'qiyamah': 75, 'kiyama': 75,
    'insan': 76, 'dahr': 76,
    'mursalat': 77,
    'naba': 78, 'naba\'i': 78, 'amma': 78,
    'naziat': 79, 'nazi\'at': 79,
    'abasa': 80,
    'takwir': 81,
    'infitar': 82,
    'mutaffifin': 83,
    'inshiqaq': 84, 'inshikak': 84,
    'buruj': 85,
    'tariq': 86, 'darik': 86,
    'ala': 87, 'a\'ala': 87,
    'ghashiyah': 88, 'gashiya': 88,
    'fajr': 89, 'fajri': 89,
    'balad': 90,
    'shams': 91, 'shamsi': 91,
    'lail': 92, 'laili': 92,
    'duha': 93, 'zuha': 93,
    'sharh': 94, 'sharhi': 94, 'alam nashrah': 94, 'inshirah': 94,
    'tin': 95, 'tini': 95,
    'alaq': 96, 'alaki': 96, 'iqra': 96, 'ikra': 96,
    'qadr': 97, 'kadri': 97, 'lailatul qadr': 97,
    'bayyinah': 98, 'bayyina': 98, 'lam yakun': 98,
    'zalzalah': 99, 'zilzala': 99, 'iza zulzilat': 99,
    'adiyat': 100,
    'qariah': 101, 'kari\'a': 101,
    'takathur': 102, 'takasur': 102, 'alhakum': 102,
    'asr': 103, 'asri': 103,
    'humazah': 104, 'humaza': 104, 'waylun': 104,
    'fil': 105, 'fili': 105, 'alam tara': 105,
    'quraysh': 106, 'kuraish': 106,
    'maun': 107, 'ma\'un': 107,
    'kawthar': 108, 'kausar': 108,
    'kafirun': 109, 'kulya': 109,
    'nasr': 110, 'nasri': 110, 'iza ja\'a': 110,
    'masad': 111, 'lahab': 111, 'tabbat': 111, 'tabat': 111,
    'ikhlas': 112, 'kulhuwa': 112, 'qulhuwa': 112, 'tauhid': 112,
    'falaq': 113, 'falak': 113, 'falaqi': 113, 'kula\'uzu birabbil falak': 113,
    'nas': 114, 'nasi': 114, 'kula\'uzu birabbin nas': 114,
  };

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Clean any orphan temp files
    await _downloadService.pruneTempFiles();

    final prefs = await SharedPreferences.getInstance();
    _wifiOnly = prefs.getBool('wifi_only') ?? true;
    final favList = prefs.getStringList('favorites') ?? [];

    // 1. Load bundled asset catalog for instant offline start
    try {
      final localJson = await rootBundle.loadString('assets/surahs.json');
      final List<dynamic> data = json.decode(localJson);
      _allSurahs = data.map((item) => Surah.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Local asset catalog load error: $e');
    }

    // Check download status for all Surahs
    for (final s in _allSurahs) {
      s.isFavorite = favList.contains(s.id.toString());
      s.isDownloaded = await _downloadService.isSurahDownloaded(s);
      if (s.isDownloaded) {
        s.localPath = await _downloadService.getLocalFilePath(s.safeFileName);
      }
    }

    _cachedSizeBytes = await _downloadService.getTotalCachedSizeBytes();
    _isLoading = false;
    notifyListeners();

    // 2. Fetch fresh catalog from VPS in background
    _fetchRemoteCatalog();
  }

  Future<void> _fetchRemoteCatalog() async {
    try {
      final response = await _dio.get('https://quran.academyhub.com.ng/surahs.json');

      if (response.statusCode == 200) {
        List<dynamic> data;
        if (response.data is List) {
          data = response.data;
        } else if (response.data is String) {
          data = json.decode(response.data);
        } else {
          return;
        }

        final freshList = data.map((item) => Surah.fromJson(item)).toList();
        final prefs = await SharedPreferences.getInstance();
        final favList = prefs.getStringList('favorites') ?? [];

        for (final s in freshList) {
          s.isFavorite = favList.contains(s.id.toString());

          // Preserve in-flight downloading state from current list
          final existing = _allSurahs.where((item) => item.id == s.id).firstOrNull;
          if (existing != null && existing.isDownloading) {
            s.isDownloading = existing.isDownloading;
            s.downloadProgress = existing.downloadProgress;
            s.isDownloaded = existing.isDownloaded;
            s.localPath = existing.localPath;
          } else {
            s.isDownloaded = await _downloadService.isSurahDownloaded(s);
            if (s.isDownloaded) {
              s.localPath = await _downloadService.getLocalFilePath(s.safeFileName);
            }
          }
        }

        _allSurahs = freshList;
        _cachedSizeBytes = await _downloadService.getTotalCachedSizeBytes();
        notifyListeners();
      }
    } catch (_) {
      // Offline or network error - bundled asset already serves content
    }
  }

  void setSearchQuery(String q) {
    _searchQuery = q.trim();
    notifyListeners();
  }

  void setActiveTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  Future<void> toggleFavorite(Surah surah) async {
    surah.isFavorite = !surah.isFavorite;
    final prefs = await SharedPreferences.getInstance();
    final favList = _allSurahs
        .where((s) => s.isFavorite)
        .map((s) => s.id.toString())
        .toList();
    await prefs.setStringList('favorites', favList);
    notifyListeners();
  }

  Future<void> toggleWifiOnly(bool value) async {
    _wifiOnly = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wifi_only', value);
    notifyListeners();
  }

  Future<void> downloadSurah(Surah surah) async {
    if (surah.isDownloading || surah.isDownloaded) return;

    surah.isDownloading = true;
    surah.downloadProgress = 0.01;
    notifyListeners();

    final path = await _downloadService.downloadSurah(
      surah: surah,
      onProgress: (progress) {
        surah.downloadProgress = progress;
        notifyListeners();
      },
    );

    surah.isDownloading = false;
    if (path != null) {
      surah.isDownloaded = true;
      surah.localPath = path;
      surah.downloadProgress = 1.0;
    } else {
      surah.downloadProgress = 0.0;
    }

    _cachedSizeBytes = await _downloadService.getTotalCachedSizeBytes();
    notifyListeners();
  }

  void cancelDownload(Surah surah) {
    _downloadService.cancelDownload(surah.id);
    surah.isDownloading = false;
    surah.downloadProgress = 0.0;
    notifyListeners();
  }

  Future<void> deleteSurah(Surah surah) async {
    await _downloadService.deleteSurah(surah);
    surah.isDownloaded = false;
    surah.localPath = null;
    surah.downloadProgress = 0.0;
    _cachedSizeBytes = await _downloadService.getTotalCachedSizeBytes();
    notifyListeners();
  }

  Future<void> downloadAllSurahs() async {
    for (final s in _allSurahs) {
      if (!s.isDownloaded && !s.isDownloading) {
        await downloadSurah(s);
      }
    }
  }

  Future<void> clearAllCache() async {
    await _downloadService.clearAllCache();
    for (final s in _allSurahs) {
      s.isDownloaded = false;
      s.localPath = null;
      s.downloadProgress = 0.0;
    }
    _cachedSizeBytes = 0;
    notifyListeners();
  }
}
