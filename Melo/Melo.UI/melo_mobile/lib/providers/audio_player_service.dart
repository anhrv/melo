import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

enum AppPlayerState { playing, paused, stopped, buffering }

class AudioPlayerService with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isExpanded = false;
  String? _currentSongUrl;
  String? _currentTitle;
  AppPlayerState _playerState = AppPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasLoadedSource = false;

  bool get isExpanded => _isExpanded;
  String? get currentSongUrl => _currentSongUrl;
  String? get currentTitle => _currentTitle;
  AudioPlayer get player => _player;
  AppPlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get hasLoadedSource => _hasLoadedSource;

  AudioPlayerService() {
    _player.playerStateStream.listen((playerState) {
      _playerState = _mapPlayerState(playerState);
      notifyListeners();
    });

    _player.durationStream.listen((duration) {
      if (duration != null) {
        _duration = duration;
        notifyListeners();
      }
    });

    _player.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _player.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _position = Duration.zero;
        _playerState = AppPlayerState.stopped;
        notifyListeners();
      }
    });
  }

  AppPlayerState _mapPlayerState(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
        return AppPlayerState.stopped;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AppPlayerState.buffering;
      case ProcessingState.ready:
        return state.playing ? AppPlayerState.playing : AppPlayerState.paused;
      case ProcessingState.completed:
        return AppPlayerState.stopped;
    }
  }

  void expandPlayer() {
    _isExpanded = true;
    notifyListeners();
  }

  void collapsePlayer() {
    _isExpanded = false;
    notifyListeners();
  }

  Future<void> playSong(String url, String title,
      {Map<String, String>? headers}) async {
    try {
      _currentSongUrl = url;
      _currentTitle = title;
      _hasLoadedSource = false;
      notifyListeners();

      await _player.stop();
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          headers: headers,
        ),
      );

      _hasLoadedSource = true;
      await _player.play();
      notifyListeners();
    } catch (e) {
      _hasLoadedSource = false;
      _playerState = AppPlayerState.stopped;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> togglePlayback() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    if (_playerState == AppPlayerState.stopped && _hasLoadedSource) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
