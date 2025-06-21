import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/models/song_response.dart';
import 'package:melo_mobile/services/song_service.dart';

enum AppPlayerState { playing, paused, stopped, buffering }

class AudioPlayerService with ChangeNotifier {
  BuildContext? _context;
  Map<String, String>? _headers;

  final SongService _songService;

  final AudioPlayer _player = AudioPlayer();
  bool _isExpanded = false;
  SongResponse? _currentSong;
  bool _isLiked = false;
  AppPlayerState _playerState = AppPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasLoadedSource = false;
  List<SongResponse>? _playlist;
  String? _playlistType;
  int? _playlistId;

  int _playlistIndex = -1;

  bool get isExpanded => _isExpanded;
  SongResponse? get currentSong => _currentSong;
  List<SongResponse>? get currentPlaylist => _playlist;
  int? get currentPlaylistId => _playlistId;
  String? get currentPlaylistType => _playlistType;
  bool get isLiked => _isLiked;
  AudioPlayer get player => _player;
  AppPlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get hasLoadedSource => _hasLoadedSource;
  bool get hasNextSong =>
      _playlist != null && _playlistIndex < _playlist!.length - 1;
  bool get hasPreviousSong => _playlist != null && _playlistIndex > 0;

  bool _isAutoAdvancing = false;

  AudioPlayerService(this._songService) {
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

    _player.playerStateStream.listen((playerState) async {
      _playerState = _mapPlayerState(playerState);
      notifyListeners();

      if (playerState.processingState == ProcessingState.completed) {
        await Future.delayed(const Duration(milliseconds: 200));

        if (_player.processingState == ProcessingState.completed &&
            !_isAutoAdvancing) {
          _isAutoAdvancing = true;

          try {
            _position = Duration.zero;
            _playerState = AppPlayerState.stopped;
            notifyListeners();

            if (_context != null && _headers != null && hasNextSong) {
              await _autoPlayNext(_context!, headers: _headers);
            }
          } finally {
            _isAutoAdvancing = false;
          }
        }
      }
    });
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void setHeaders(Map<String, String>? headers) {
    _headers = headers;
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
      {Map<String, String>? headers,
      List<SongResponse>? playlist,
      int? playlistId,
      String? playlistType,
      int? index}) async {
    setContext(context);
    setHeaders(headers);

    final rawUrl = song.audioUrl;
    if (rawUrl == null) return;

    final fullUrl = ApiConstants.fileServer + rawUrl;

    try {
      _currentSong = song;
      _hasLoadedSource = false;

      if (playlist != null) {
        _playlist = playlist;
        _playlistId = playlistId;
        _playlistType = playlistType;

        if (index != null) {
          _playlistIndex = index;
        } else {
          _playlistIndex = playlist.indexWhere((s) => s.id == song.id);
        }
      } else {
        _playlist = null;
        _playlistId = null;
        _playlistType = null;
        _playlistIndex = -1;
      }

      notifyListeners();

      if (_player.playing ||
          _player.processingState != ProcessingState.completed) {
        await _player.stop();
      }
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(fullUrl), headers: headers),
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

  Future<void> playNextSong(BuildContext context,
      {Map<String, String>? headers}) async {
    if (!hasNextSong) return;
    _playlistIndex++;
    final next = _playlist![_playlistIndex];
    await playSong(next, context,
        headers: headers,
        playlist: _playlist,
        playlistId: _playlistId,
        playlistType: _playlistType,
        index: _playlistIndex);
  }

  Future<void> playPreviousSong(BuildContext context,
      {Map<String, String>? headers}) async {
    if (!hasPreviousSong) return;
    _playlistIndex--;
    final prev = _playlist![_playlistIndex];
    await playSong(prev, context,
        headers: headers,
        playlist: _playlist,
        playlistId: _playlistId,
        playlistType: _playlistType,
        index: _playlistIndex);
  }

  Future<void> _autoPlayNext(BuildContext context,
      {Map<String, String>? headers}) async {
    if (hasNextSong && _currentSong != null) {
      await playNextSong(context, headers: headers);
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

  Future<bool> addToPlaylists(
      List<LovResponse>? _selectedPlaylists, BuildContext context) async {
    if (currentSong?.id == null) return false;
    final success = await _songService.addToPlaylists(
      currentSong!.id,
      _selectedPlaylists != null && _selectedPlaylists.isNotEmpty
          ? _selectedPlaylists.map((g) => g.id).toList()
          : null,
      context,
    );
    return success;
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
    _playlist = null;
    _playlistId = null;
    _playlistType = null;
    _playlistIndex = -1;
    await _player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
