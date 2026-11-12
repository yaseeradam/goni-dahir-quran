import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/surah.dart';

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final List<StreamSubscription> _subscriptions = [];

  Surah? _currentSurah;
  List<Surah> _playlist = [];
  List<int>? _loadedPlaylistIds;
  Set<int> _loadedDownloadedIds = {};
  Uri? _cachedArtUri;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _playInterrupted = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _speed = 1.0;
  LoopMode _loopMode = LoopMode.off;
  bool _isShuffle = false;
  List<int> _shufflePool = [];
  int _shuffleIndex = 0;
  int _sleepTimerMinutes = 0;
  Timer? _sleepTimer;
  String? _errorMessage;
  bool _lockScreenControls = true;
  bool _isDisposed = false;

  Surah? get currentSurah => _currentSurah;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  double get speed => _speed;
  LoopMode get loopMode => _loopMode;
  bool get isShuffle => _isShuffle;
  bool get isAutoReplay => _loopMode == LoopMode.one;
  bool get lockScreenControls => _lockScreenControls;
  int get sleepTimerMinutes => _sleepTimerMinutes;
  bool get hasCurrentSurah => _currentSurah != null;
  String? get errorMessage => _errorMessage;

  double get progressPercentage {
    if (_duration.inMilliseconds > 0) {
      return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  AudioPlayerProvider() {
    _loadSettings();
    _initAudioSession();
    _listenToPlayerStreams();
    _prepareNotificationArt();
  }

  Future<Uri?> _prepareNotificationArt() async {
    if (_cachedArtUri != null) return _cachedArtUri;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final artFile = File('${docDir.path}/goni_dahir_notification_art.png');
      if (!await artFile.exists() || await artFile.length() == 0) {
        final byteData = await rootBundle.load('assets/logo.png');
        await artFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      }
      _cachedArtUri = Uri.file(artFile.path);
      return _cachedArtUri;
    } catch (e) {
      debugPrint('Error preparing notification art: $e');
      return Uri.parse('https://quran.academyhub.com.ng/logo.png');
    }
  }

  void invalidatePlaylist() {
    _loadedPlaylistIds = null;
    _loadedDownloadedIds.clear();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lockScreenControls = prefs.getBool('lock_screen_controls') ?? true;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleLockScreenControls(bool value) async {
    _lockScreenControls = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('lock_screen_controls', value);
    } catch (_) {}
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _subscriptions.add(session.interruptionEventStream.listen((event) {
        if (event.begin) {
          if (event.type == AudioInterruptionType.pause ||
              event.type == AudioInterruptionType.unknown) {
            _playInterrupted = _isPlaying;
            pause();
          }
        } else {
          if (event.type == AudioInterruptionType.pause && _playInterrupted) {
            _playInterrupted = false;
            resume();
          }
        }
      }));

      _subscriptions.add(session.becomingNoisyEventStream.listen((_) {
        // Headphone unplugged: pause playback
        pause();
      }));
    } catch (e) {
      debugPrint('AudioSession init error: $e');
    }
  }

  void _listenToPlayerStreams() {
    _subscriptions.add(_player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isBuffering = state.processingState == ProcessingState.buffering;

      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one) {
          // Auto-replay: repeat the current Surah seamlessly upon completion
          seek(Duration.zero);
          resume();
        } else if (_isShuffle) {
          nextSurah(loopAround: _loopMode == LoopMode.all);
        } else if (_loopMode == LoopMode.all) {
          nextSurah(loopAround: true);
        } else {
          // LoopMode.off: stop at end of current track
          seek(Duration.zero);
          pause();
        }
      }
      if (!_isDisposed) notifyListeners();
    }));

    _subscriptions.add(_player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _playlist.length) {
        final newSurah = _playlist[index];
        if (_currentSurah?.id != newSurah.id) {
          _currentSurah = newSurah;
          if (!_isDisposed) notifyListeners();
        }
      }
    }));

    _subscriptions.add(_player.positionStream.listen((pos) {
      _position = pos;
      if (!_isDisposed) notifyListeners();
    }));

    _subscriptions.add(_player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      if (!_isDisposed) notifyListeners();
    }));

    _subscriptions.add(_player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        debugPrint('Audio playback stream error: $e');
        _isBuffering = false;
        _isPlaying = false;
        _errorMessage = 'Connection interrupted. Tap to retry.';
        if (!_isDisposed) notifyListeners();
      },
    ));
  }

  void _rebuildShufflePool() {
    if (_playlist.isEmpty) {
      _shufflePool = [];
      _shuffleIndex = 0;
      return;
    }

    final currentId = _currentSurah?.id;
    final currentIdx = _playlist.indexWhere((s) => s.id == currentId);

    // Collect all indices excluding the current one to form a non-repeating deck
    final remainingIndices = [
      for (int i = 0; i < _playlist.length; i++)
        if (i != currentIdx) i
    ]..shuffle();

    if (currentIdx != -1) {
      // Pin current playing Surah at index 0 so it won't repeat later in the cycle
      _shufflePool = [currentIdx, ...remainingIndices];
    } else {
      _shufflePool = List<int>.generate(_playlist.length, (i) => i)..shuffle();
    }
    _shuffleIndex = 0;
  }

  Future<void> playSurah(
    Surah surah,
    List<Surah> playlist, {
    bool fromShuffle = false,
  }) async {
    _currentSurah = surah;
    _playlist = playlist;
    _errorMessage = null;

    if (_isShuffle && !fromShuffle) {
      // User picked a specific Surah while shuffle is active: re-anchor shuffle pool
      _rebuildShufflePool();
    }

    notifyListeners();

    try {
      if (Platform.isAndroid && _lockScreenControls) {
        try {
          final status = await Permission.notification.status;
          if (!status.isGranted) {
            await Permission.notification.request();
          }
        } catch (_) {}
      }

      final session = await AudioSession.instance;
      await session.setActive(true);

      final artUri = await _prepareNotificationArt();
      final targetIndex = playlist.indexWhere((s) => s.id == surah.id);
      final initialIndex = targetIndex != -1 ? targetIndex : 0;

      final currentDownloadedIds = playlist
          .where((s) => s.isDownloaded && s.localPath != null && File(s.localPath!).existsSync())
          .map((s) => s.id)
          .toSet();
      final incomingIds = playlist.map((s) => s.id).toList();
      final canReuseSource = _loadedPlaylistIds != null &&
          setEquals(_loadedDownloadedIds, currentDownloadedIds) &&
          listEquals(_loadedPlaylistIds, incomingIds) &&
          _player.audioSource != null;

      if (canReuseSource) {
        await _player.seek(Duration.zero, index: initialIndex);
      } else {
        _loadedDownloadedIds = currentDownloadedIds;
        final sources = playlist.map((s) {
          final isLocal = s.isDownloaded && s.localPath != null && File(s.localPath!).existsSync();
          final uri = isLocal ? Uri.file(s.localPath!) : Uri.parse(s.audioUrl);

          return AudioSource.uri(
            uri,
            tag: _lockScreenControls
                ? MediaItem(
                    id: s.id.toString(),
                    album: "Goni Dahir Idris Maiduguri • Hafs 'an 'Asim",
                    title: "Surah ${s.name} (${s.arabic})",
                    artist: "Goni Dahir Idris Maiduguri",
                    artUri: artUri,
                  )
                : null,
          );
        }).toList();

        _loadedPlaylistIds = incomingIds;
        await _player.setAudioSources(
          sources,
          initialIndex: initialIndex,
          initialPosition: Duration.zero,
        );
      }

      await _player.setSpeed(_speed);
      await _player.play();
    } catch (e) {
      debugPrint('Error playing ${surah.name}: $e');
      _isPlaying = false;
      _errorMessage = 'Unable to play recitation. Please check your network connection.';
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    try {
      final session = await AudioSession.instance;
      await session.setActive(true);
      await _player.play();
    } catch (e) {
      debugPrint('Resume error: $e');
    }
  }

  Future<void> seek(Duration pos) async {
    await _player.seek(pos);
  }

  Future<void> seekBy(int seconds) async {
    final target = _position + Duration(seconds: seconds);
    final clamped = Duration(
      milliseconds: target.inMilliseconds.clamp(0, _duration.inMilliseconds),
    );
    await _player.seek(clamped);
  }

  Future<void> nextSurah({bool loopAround = false}) async {
    if (_playlist.isEmpty || _currentSurah == null) return;

    if (_isShuffle && _shufflePool.isNotEmpty) {
      if (_shuffleIndex + 1 < _shufflePool.length) {
        _shuffleIndex++;
        final nextIdx = _shufflePool[_shuffleIndex];
        await playSurah(_playlist[nextIdx], _playlist, fromShuffle: true);
      } else if (_loopMode == LoopMode.all || loopAround) {
        // Complete cycle of 60 Surahs exhausted - re-shuffle without back-to-back repeat
        final lastIdx = _shufflePool.isNotEmpty ? _shufflePool.last : -1;
        final newPool = List<int>.generate(_playlist.length, (i) => i)..shuffle();
        if (newPool.length > 1 && newPool.first == lastIdx) {
          final temp = newPool[0];
          newPool[0] = newPool[newPool.length - 1];
          newPool[newPool.length - 1] = temp;
        }
        _shufflePool = newPool;
        _shuffleIndex = 0;
        await playSurah(_playlist[_shufflePool[0]], _playlist, fromShuffle: true);
      } else {
        await seek(Duration.zero);
        await pause();
      }
      return;
    }

    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      final index = _playlist.indexWhere((s) => s.id == _currentSurah!.id);
      if (index != -1 && index + 1 < _playlist.length) {
        await playSurah(_playlist[index + 1], _playlist);
      } else if (loopAround && _playlist.isNotEmpty) {
        await playSurah(_playlist[0], _playlist);
      }
    }
  }

  Future<void> previousSurah() async {
    if (_playlist.isEmpty || _currentSurah == null) return;
    if (_position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    if (_isShuffle && _shufflePool.isNotEmpty) {
      if (_shuffleIndex > 0) {
        _shuffleIndex--;
        final prevIdx = _shufflePool[_shuffleIndex];
        await playSurah(_playlist[prevIdx], _playlist, fromShuffle: true);
      } else {
        await seek(Duration.zero);
      }
      return;
    }

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      final index = _playlist.indexWhere((s) => s.id == _currentSurah!.id);
      if (index > 0) {
        await playSurah(_playlist[index - 1], _playlist);
      }
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_isShuffle) {
      _rebuildShufflePool();
    } else {
      _shufflePool.clear();
      _shuffleIndex = 0;
    }
    _player.setShuffleModeEnabled(_isShuffle);
    notifyListeners();
  }

  void toggleAutoReplay() {
    if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.off;
    } else {
      _loopMode = LoopMode.one;
    }
    _player.setLoopMode(_loopMode);
    notifyListeners();
  }

  Future<void> setSpeed(double newSpeed) async {
    _speed = newSpeed;
    await _player.setSpeed(_speed);
    notifyListeners();
  }

  void toggleLoopMode() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    _player.setLoopMode(_loopMode);
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    _sleepTimerMinutes = minutes;

    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        pause();
        _sleepTimerMinutes = 0;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sleepTimer?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    _player.dispose();
    AudioSession.instance.then((s) {
      s.setActive(false);
    }).catchError((_) {});
    super.dispose();
  }
}
