import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/models/song_response.dart';
import 'package:melo_mobile/services/song_service.dart';

enum AppPlayerState { playing, paused, stopped, buffering }

class AudioPlayerService with ChangeNotifier {
  final SongService _songService;

  final AudioPlayer _player = AudioPlayer();
  bool _isExpanded = false;
  SongResponse? _currentSong;
  bool _isLiked = false;
  AppPlayerState _playerState = AppPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasLoadedSource = false;

  bool get isExpanded => _isExpanded;
  SongResponse? get currentSong => _currentSong;
  bool get isLiked => _isLiked;
  AudioPlayer get player => _player;
  AppPlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get hasLoadedSource => _hasLoadedSource;

  AudioPlayerService(this._songService) {
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

  Future<void> playSong(SongResponse song, BuildContext context,
      {Map<String, String>? headers}) async {
    final rawUrl = song.audioUrl;
    if (rawUrl == null) return;

    final fullUrl = ApiConstants.fileServer + rawUrl;

    try {
      _currentSong = song;
      _hasLoadedSource = false;
      notifyListeners();

      await _player.stop();
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(fullUrl),
          headers: headers,
        ),
      );

      await _fetchLikedStatus(song.id, context);

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

  Future<void> _fetchLikedStatus(int songId, BuildContext context) async {
    try {
      final liked = await _songService.isLiked(songId, context);
      _isLiked = liked;
      notifyListeners();
    } catch (_) {
      _isLiked = false;
    }
  }

  Future<void> toggleLikedStatus(BuildContext context) async {
    if (_currentSong == null) return;

    try {
      if (_isLiked) {
        await _songService.unlike(_currentSong!.id, context);
      } else {
        await _songService.like(_currentSong!.id, context);
      }

      _isLiked = !_isLiked;
      notifyListeners();
    } catch (_) {}
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

  Future<void> closePlayer() async {
    _currentSong = null;
    _isLiked = false;
    _hasLoadedSource = false;
    _duration = Duration.zero;
    _position = Duration.zero;
    _playerState = AppPlayerState.stopped;
    _isExpanded = false;
    await _player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
