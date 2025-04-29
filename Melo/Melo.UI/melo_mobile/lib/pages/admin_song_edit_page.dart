import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/pages/admin_artist_add_page.dart';
import 'package:melo_mobile/pages/admin_artist_edit_page.dart';
import 'package:melo_mobile/pages/admin_genre_add_page.dart';
import 'package:melo_mobile/pages/admin_genre_edit_page.dart';
import 'package:melo_mobile/services/song_service.dart';
import 'package:melo_mobile/services/artist_service.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminSongEditPage extends StatefulWidget {
  final int songId;
  final bool initialEditMode;

  const AdminSongEditPage({
    super.key,
    required this.songId,
    this.initialEditMode = false,
  });

  @override
  State<AdminSongEditPage> createState() => _AdminSongEditPageState();
}

class _AdminSongEditPageState extends State<AdminSongEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late SongService _songService;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;

  late ArtistService _artistService;
  List<LovResponse> _selectedArtists = [];
  List<LovResponse> _originalArtists = [];

  late GenreService _genreService;
  List<LovResponse> _selectedGenres = [];
  List<LovResponse> _originalGenres = [];

  DateTime? _selectedDate;
  DateTime? _originalDate;

  String? originalName;
  String? originalImageUrl;
  String? playtime;
  int? viewCount;
  int? likeCount;

  bool _isImageRemoved = false;
  bool _isEditMode = false;

  File? _audioFile;
  String? _audioError;
  late AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? originalAudioUrl;
  bool _isAudioRemoved = false;

  @override
  void initState() {
    super.initState();
    _songService = SongService(context);
    _artistService = ArtistService(context);
    _genreService = GenreService(context);
    _isEditMode = widget.initialEditMode;
    _audioPlayer = AudioPlayer()
      ..onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _playerState = state);
      })
      ..onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      })
      ..onPositionChanged.listen((position) {
        if (mounted) setState(() => _position = position);
      })
      ..onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _position = Duration.zero;
            _playerState = PlayerState.stopped;
          });
        }
      });
    _fetchSong();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleSeek(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  Future<void> _fetchSong() async {
    setState(() => _isLoading = true);
    final song = await _songService.getById(widget.songId, context);
    if (song != null) {
      setState(() {
        originalName = song.name ?? "";
        originalImageUrl = song.imageUrl;
        originalAudioUrl = song.audioUrl;
        viewCount = song.viewCount ?? 0;
        likeCount = song.likeCount ?? 0;
        playtime = song.playtime ?? "0:00";
        _originalDate = song.dateOfRelease != null
            ? DateTime.parse(song.dateOfRelease!)
            : null;
        _selectedDate = _originalDate;
        _selectedGenres = song.genres
            .map((g) => LovResponse(id: g.id, name: g.name ?? "No name"))
            .toList();
        _originalGenres = List.from(_selectedGenres);
        _selectedArtists = song.artists
            .map((a) => LovResponse(id: a.id, name: a.name ?? "No name"))
            .toList();
        _originalArtists = List.from(_selectedArtists);
        _nameController.text = originalName ?? "";
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      if (file.extension?.toLowerCase() == 'mp3' && file.path != null) {
        setState(() {
          _audioFile = File(file.path!);
          _audioError = null;
          _isAudioRemoved = false;
        });
      } else {
        setState(() {
          _audioError = 'Only MP3 files are allowed';
          _audioFile = null;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final extension = pickedFile.path.split('.').last.toLowerCase();
      if (extension == 'jpg' || extension == 'jpeg') {
        setState(() {
          _imageFile = File(pickedFile.path);
          _isImageRemoved = false;
          _imageError = null;
        });
      } else {
        setState(() {
          _imageFile = null;
          _imageError = 'Only JPG or JPEG images are allowed.';
        });
      }
    }
  }

  void _cancelEdit() {
    if (_playerState == PlayerState.playing) {
      _audioPlayer.stop();
    }
    _formKey.currentState?.reset();
    setState(() {
      _isEditMode = false;
      _nameController.text = originalName ?? "";
      _imageFile = null;
      _isImageRemoved = false;
      _imageError = null;
      _audioFile = null;
      _isAudioRemoved = false;
      _audioError = null;
      _position = Duration.zero;
      _duration = Duration.zero;
      _fieldErrors = {};
      _selectedGenres = _originalGenres.toList();
      _selectedArtists = _originalArtists.toList();
      _selectedDate = _originalDate;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _formKey.currentState?.validate();
      }
    });
  }

  bool get _hasChanges {
    final nameChanged = _nameController.text != originalName;
    final imageChanged = _imageFile != null || _isImageRemoved;
    final genresChanged = !const SetEquality()
        .equals(_selectedGenres.toSet(), _originalGenres.toSet());
    final artistsChanged = !const SetEquality()
        .equals(_selectedArtists.toSet(), _originalArtists.toSet());
    final dateChanged = _selectedDate != _originalDate;
    final audioChanged = _audioFile != null || _isAudioRemoved;

    return nameChanged ||
        imageChanged ||
        genresChanged ||
        artistsChanged ||
        dateChanged ||
        audioChanged;
  }

  Future<void> _saveChanges() async {
    if (_isLoading || !_hasChanges) return;

    setState(() {
      _fieldErrors = {};
      _audioError = null;
    });

    if ((_audioFile == null && _isAudioRemoved && originalAudioUrl != null) ||
        (originalAudioUrl == null && _audioFile == null)) {
      setState(() => _audioError = 'Audio file is required');
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    if (_audioError != null) return;

    setState(() {
      _isLoading = true;
    });
    FocusScope.of(context).unfocus();

    try {
      final newName = _nameController.text;
      bool nameChanged = newName != originalName;
      bool dateChanged = _selectedDate != _originalDate;
      bool imageChanged = _imageFile != null || _isImageRemoved;
      bool genresChanged = !const SetEquality()
          .equals(_selectedGenres.toSet(), _originalGenres.toSet());
      bool artistsChanged = !const SetEquality()
          .equals(_selectedArtists.toSet(), _originalArtists.toSet());

      if (nameChanged || dateChanged || genresChanged || artistsChanged) {
        final updated = await _songService.update(
          widget.songId,
          newName,
          _selectedDate,
          _selectedArtists.isNotEmpty
              ? _selectedArtists.map((a) => a.id).toList()
              : null,
          _selectedGenres.isNotEmpty
              ? _selectedGenres.map((g) => g.id).toList()
              : null,
          context,
          (errors) => setState(() => _fieldErrors = errors),
        );
        if (updated == null) return;
        originalName = newName;
        _originalDate = _selectedDate;
        _originalGenres = _selectedGenres.toList();
        _originalArtists = _selectedArtists.toList();
      }

      if (imageChanged && mounted) {
        final success = await _songService.setImage(
          widget.songId,
          _isImageRemoved ? null : _imageFile,
          context,
        );
        if (!success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to update image',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      if (_audioFile != null && mounted) {
        final audioSuccess = await _songService.setAudio(
          widget.songId,
          _audioFile!,
          context,
        );

        if (!audioSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Failed to update audio',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.redAccent,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }

      await _fetchSong();
      _cancelEdit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Song updated successfully',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.redAccent,
                ),
              ),
            ),
            IconButton(
              iconSize: 22,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context, false),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this song? This action is permanent.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
                )),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final success = await _songService.delete(widget.songId, context);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Song deleted successfully",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.greenAccent,
            duration: Duration(seconds: 2),
          ),
        );
        setState(() => _isLoading = false);
        Navigator.pop(context);
      }
    }
  }

  void _toggleAudio() async {
    if (_audioFile != null) {
      await _audioPlayer.play(DeviceFileSource(_audioFile!.path));
    } else if (originalAudioUrl != null && !_isAudioRemoved) {
      try {
        final source = UrlSource(
          originalAudioUrl!,
        );
        await _audioPlayer.setSource(source);
        await _audioPlayer.resume();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playback error: ${e.toString()}'),
              backgroundColor: AppColors.redAccent,
            ),
          );
        }
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildAudioUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _isEditMode ? _pickAudio : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.1),
              border: Border.all(color: AppColors.white54, width: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.audio_file, color: AppColors.secondary),
                const SizedBox(width: 12),
                if (_shouldShowAudioContent) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _audioFileName,
                          style: const TextStyle(color: AppColors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _playerState == PlayerState.playing
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: AppColors.secondary,
                              ),
                              onPressed: _toggleAudio,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: const SliderThemeData(
                                  trackHeight: 2,
                                  thumbShape: RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  overlayShape: RoundSliderOverlayShape(
                                    overlayRadius: 12,
                                  ),
                                  activeTrackColor: AppColors.secondary,
                                  inactiveTrackColor: AppColors.grey,
                                  thumbColor: AppColors.secondary,
                                ),
                                child: Slider(
                                  min: 0,
                                  max: _duration.inSeconds.toDouble(),
                                  value: _position.inSeconds.toDouble(),
                                  onChanged: _handleSeek,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_position)),
                              Text(_formatDuration(_duration)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isEditMode && _hasAudioSelection)
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white),
                      onPressed: () => setState(() {
                        if (_audioFile != null) {
                          _audioFile = null;
                        } else {
                          _isAudioRemoved = true;
                        }
                        _position = Duration.zero;
                        _duration = Duration.zero;
                      }),
                    ),
                ] else
                  Text(
                    _isEditMode ? 'Audio file (MP3)' : 'No audio file',
                    style: TextStyle(
                      color: _isEditMode ? AppColors.white70 : AppColors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_audioError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _audioError!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
      ],
    );
  }

  bool get _hasAudioSelection =>
      _audioFile != null || (originalAudioUrl != null && !_isAudioRemoved);

  bool get _shouldShowAudioContent => _hasAudioSelection;

  String get _audioFileName {
    if (_audioFile != null) return _audioFile!.path.split('/').last;
    if (originalAudioUrl != null && !_isAudioRemoved) return "Original Audio";
    return "";
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _isEditMode ? _pickImage : null,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  border: Border.all(color: AppColors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildImageContent(),
              ),
            ),
            if (_shouldShowCloseButton)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (_imageFile != null) {
                      _imageFile = null;
                    } else {
                      _isImageRemoved = true;
                    }
                  }),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (_imageError != null) ...[
          const SizedBox(height: 16),
          Text(
            _imageError!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent() {
    if (_imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(_imageFile!, fit: BoxFit.cover),
      );
    }

    if (_isImageRemoved ||
        originalImageUrl == null ||
        originalImageUrl!.isEmpty) {
      if (_isEditMode) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 40),
            SizedBox(height: 8),
            Text(
              'Image\nJPG / JPEG',
              textAlign: TextAlign.center,
            ),
          ],
        );
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 150,
          height: 150,
          color: AppColors.grey,
          child: const Icon(Icons.music_note, size: 40),
        ),
      );
    }

    return CustomImage(
      imageUrl: originalImageUrl!,
      width: 150,
      height: 150,
      borderRadius: 8,
      iconData: Icons.music_note,
    );
  }

  bool get _shouldShowCloseButton {
    return _isEditMode &&
        (_imageFile != null || (!_isImageRemoved && originalImageUrl != null));
  }

  Future<void> _selectDate() async {
    if (!_isEditMode) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleGenreSelection(List<LovResponse> selected) {
    setState(() => _selectedGenres = selected);
  }

  void _handleArtistSelection(List<LovResponse> selected) {
    setState(() => _selectedArtists = selected);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Song details"),
        drawer: const AdminAppDrawer(),
        endDrawer: const UserDrawer(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageUpload(),
                const SizedBox(height: 24),
                _buildAudioUpload(),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: _fieldErrors['Name'],
                  ),
                  readOnly: !_isEditMode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Song name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_isEditMode) {
                      setState(() {});
                    }
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Release date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          errorText: _fieldErrors['DateOfRelease'],
                          suffixIcon: _isEditMode && _selectedDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () =>
                                      setState(() => _selectedDate = null),
                                )
                              : _isEditMode
                                  ? const Icon(Icons.calendar_today)
                                  : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                              : 'No release date',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Artists',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _selectedArtists.isEmpty && !_isEditMode
                            ? const Text("No artists")
                            : Wrap(
                                spacing: 8,
                                children: _selectedArtists.map((artist) {
                                  return GestureDetector(
                                      onTap: _isEditMode
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AdminArtistEditPage(
                                                    artistId: artist.id,
                                                    initialEditMode: false,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Chip(
                                        label: Text(artist.name),
                                        deleteIcon: _isEditMode
                                            ? const Icon(Icons.close, size: 18)
                                            : null,
                                        onDeleted: _isEditMode
                                            ? () => setState(() =>
                                                _selectedArtists.remove(artist))
                                            : null,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: _isEditMode
                                                ? AppColors.white70
                                                : AppColors.secondary,
                                            width: 0.5,
                                          ),
                                        ),
                                        backgroundColor: AppColors.background,
                                        deleteIconColor: AppColors.grey,
                                      ));
                                }).toList(),
                              ),
                        if (_isEditMode) ...[
                          const SizedBox(
                            height: 12,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "Select artists",
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 14,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final selected =
                                            await showDialog<List<LovResponse>>(
                                          context: context,
                                          builder: (context) =>
                                              MultiSelectDialog(
                                            fetchOptions: (searchTerm) =>
                                                _artistService.getLov(context,
                                                    name: searchTerm),
                                            selected: _selectedArtists,
                                            addOptionPage:
                                                const AdminArtistAddPage(),
                                          ),
                                        );
                                        if (selected != null) {
                                          _handleArtistSelection(selected);
                                        }
                                      },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Genres',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _selectedGenres.isEmpty && !_isEditMode
                            ? const Text("No genres")
                            : Wrap(
                                spacing: 8,
                                children: _selectedGenres.map((genre) {
                                  return GestureDetector(
                                      onTap: _isEditMode
                                          ? null
                                          : () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      AdminGenreEditPage(
                                                    genreId: genre.id,
                                                    initialEditMode: false,
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Chip(
                                        label: Text(genre.name),
                                        deleteIcon: _isEditMode
                                            ? const Icon(Icons.close, size: 18)
                                            : null,
                                        onDeleted: _isEditMode
                                            ? () => setState(() =>
                                                _selectedGenres.remove(genre))
                                            : null,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          side: BorderSide(
                                            color: _isEditMode
                                                ? AppColors.white70
                                                : AppColors.secondary,
                                            width: 0.5,
                                          ),
                                        ),
                                        backgroundColor: AppColors.background,
                                        deleteIconColor: AppColors.grey,
                                      ));
                                }).toList(),
                              ),
                        if (_isEditMode) ...[
                          const SizedBox(
                            height: 12,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: AppColors.secondary,
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                RichText(
                                  text: TextSpan(
                                    text: "Select genres",
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 14,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        final selected =
                                            await showDialog<List<LovResponse>>(
                                          context: context,
                                          builder: (context) =>
                                              MultiSelectDialog(
                                            fetchOptions: (searchTerm) =>
                                                _genreService.getLov(context,
                                                    name: searchTerm),
                                            selected: _selectedGenres,
                                            addOptionPage:
                                                const AdminGenreAddPage(),
                                          ),
                                        );
                                        if (selected != null) {
                                          _handleGenreSelection(selected);
                                        }
                                      },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (!_isEditMode) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Playtime: ${playtime ?? "0:00"}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.visibility,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Views: ${viewCount ?? 0}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 24),
                      const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Likes: ${likeCount ?? 0}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 40),
                _isEditMode ? _buildEditButtons() : _buildViewButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => setState(() => _isEditMode = true),
            child: const Text('Edit'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmDelete,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _hasChanges ? _saveChanges : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _hasChanges ? null : AppColors.grey.withOpacity(0.5),
            ),
            child: const Text('Save'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _cancelEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey,
            ),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}
