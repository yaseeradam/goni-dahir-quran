import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../models/surah.dart';

class DownloadService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 120),
    sendTimeout: const Duration(seconds: 15),
  ));

  final Map<int, CancelToken> _activeTokens = {};

  Future<String> getAudioDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${docs.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  Future<String> getLocalFilePath(String safeFileName) async {
    final dir = await getAudioDirectory();
    return '$dir/$safeFileName';
  }

  bool isDownloading(int surahId) => _activeTokens.containsKey(surahId);

  void cancelDownload(int surahId) {
    final token = _activeTokens[surahId];
    if (token != null && !token.isCancelled) {
      token.cancel('Download cancelled by user');
    }
    _activeTokens.remove(surahId);
  }

  Future<bool> isSurahDownloaded(Surah surah) async {
    final filePath = await getLocalFilePath(surah.safeFileName);
    final file = File(filePath);
    if (!await file.exists()) return false;

    final size = await file.length();
    // A valid MP3 surah must be at least 50KB
    if (size < 50000) return false;

    // If expected size is available, verify at least 90% was downloaded
    if (surah.sizeBytes > 0 && size < (surah.sizeBytes * 0.90)) {
      return false;
    }

    return true;
  }

  Future<String?> downloadSurah({
    required Surah surah,
    required void Function(double progress) onProgress,
  }) async {
    final savePath = await getLocalFilePath(surah.safeFileName);
    final tempPath = '$savePath.tmp';

    // Cancel any existing in-flight download for this surah
    cancelDownload(surah.id);
    final token = CancelToken();
    _activeTokens[surah.id] = token;

    try {
      await _dio.download(
        surah.audioUrl,
        tempPath,
        cancelToken: token,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            onProgress(received / total);
          } else if (surah.sizeBytes > 0) {
            onProgress((received / surah.sizeBytes).clamp(0.0, 1.0));
          }
        },
      );

      final tempFile = File(tempPath);
      if (!await tempFile.exists()) return null;

      final downloadedBytes = await tempFile.length();

      // Integrity checks: minimum size
      if (downloadedBytes < 50000) {
        await tempFile.delete();
        return null;
      }

      if (surah.sizeBytes > 0 && downloadedBytes < (surah.sizeBytes * 0.90)) {
        await tempFile.delete();
        return null;
      }

      // Check header bytes to avoid saving HTML or JSON error responses as MP3
      final headerStream = tempFile.openRead(0, 256);
      final headerBytes = await headerStream.first;
      final headerAscii = ascii.decode(headerBytes, allowInvalid: true).toLowerCase();
      if (headerAscii.contains('<html') ||
          headerAscii.contains('<!doctype') ||
          headerAscii.contains('{"error"') ||
          headerAscii.contains('404 not found') ||
          headerAscii.contains('502 bad gateway')) {
        await tempFile.delete();
        return null;
      }

      // Atomic swap: safely replace destination
      final destFile = File(savePath);
      if (await destFile.exists()) {
        await destFile.delete();
      }

      await tempFile.rename(savePath);
      return savePath;
    } catch (e) {
      // Clean up temp file on error or cancel
      try {
        final tempFile = File(tempPath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
      return null;
    } finally {
      _activeTokens.remove(surah.id);
    }
  }

  Future<bool> deleteSurah(Surah surah) async {
    cancelDownload(surah.id);
    try {
      final path = await getLocalFilePath(surah.safeFileName);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<int> getTotalCachedSizeBytes() async {
    try {
      final dir = Directory(await getAudioDirectory());
      if (!await dir.exists()) return 0;
      int total = 0;
      await for (final file in dir.list(recursive: false)) {
        if (file is File && file.path.endsWith('.mp3')) {
          total += await file.length();
        }
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> pruneTempFiles() async {
    try {
      final dir = Directory(await getAudioDirectory());
      if (!await dir.exists()) return;
      await for (final file in dir.list(recursive: false)) {
        if (file is File && file.path.endsWith('.tmp')) {
          await file.delete();
        }
      }
    } catch (_) {}
  }

  Future<void> clearAllCache() async {
    for (final token in _activeTokens.values) {
      if (!token.isCancelled) token.cancel('Clearing cache');
    }
    _activeTokens.clear();

    try {
      final dir = Directory(await getAudioDirectory());
      if (await dir.exists()) {
        await for (final file in dir.list(recursive: false)) {
          if (file is File) {
            await file.delete();
          }
        }
      }
    } catch (_) {}
  }
}
