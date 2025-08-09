import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/pages/admin_artist_add_page.dart';
import 'package:melo_desktop/pages/admin_genre_add_page.dart';
import 'package:melo_desktop/services/song_service.dart';
import 'package:melo_desktop/services/artist_service.dart';
import 'package:melo_desktop/services/genre_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/admin_app_drawer.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:melo_desktop/widgets/multi_select_dialog.dart';
import 'package:melo_desktop/widgets/user_drawer.dart';
import 'package:file_picker/file_picker.dart';

class AdminSongAddPage extends StatefulWidget {
  const AdminSongAddPage({super.key});

  @override
  State<AdminSongAddPage> createState() => _AdminSongAddPageState();
}

enum AppPlayerState { playing, paused, stopped }

class _AdminSongAddPageState extends State<AdminSongAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  DateTime? _selectedDate;

  late ArtistService _artistService;
  List<LovResponse> _selectedArtists = [];

  late GenreService _genreService;
  List<LovResponse> _selectedGenres = [];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;

  File? _audioFile;
  String? _audioError;
  late AudioPlayer _audioPlayer;
  AppPlayerState _playerState = AppPlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _hasLoadedSource = false;
  double? _dragValue;

  bool _isLoading = false;

  Map<String, String> _fieldErrors = {};

  late SongService _songService;

  @override
  void initState() {
    super.initState();
    _songService = SongService(context);
    _artistService = ArtistService(context);
    _genreService = GenreService(context);

    _audioPlayer = AudioPlayer();

    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        setState(() {
          _playerState = _mapJustAudioState(playerState);
        });
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted && duration != null) {
        setState(() => _duration = duration);
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted && playerState.processingState == ProcessingState.completed) {
        setState(() {
          _position = Duration.zero;
          _playerState = AppPlayerState.stopped;
        });
      }
    });
  }

  AppPlayerState _mapJustAudioState(PlayerState state) {
    switch (state.processingState) {
      case ProcessingState.idle:
      case ProcessingState.ready:
        return state.playing ? AppPlayerState.playing : AppPlayerState.paused;
      case ProcessingState.completed:
        return AppPlayerState.stopped;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        return AppPlayerState.paused;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickAudio() async {
    if (_playerState == AppPlayerState.playing) {
      _audioPlayer.stop();
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      if (file.extension?.toLowerCase() == 'mp3' && file.path != null) {
        final filePath = file.path!;

        await _audioPlayer.setFilePath(filePath);
        final duration = _audioPlayer.duration;

        setState(() {
          _audioFile = File(filePath);
          _audioError = null;
          _hasLoadedSource = true;
          _position = Duration.zero;
          _duration = duration ?? Duration.zero;
        });
      } else {
        setState(() {
          _audioError = 'Only MP3 files are allowed';
          _audioFile = null;
          _hasLoadedSource = false;
        });
      }
    }
  }

  void _toggleAudio() async {
    if (_audioFile == null) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
      return;
    }

    if (_audioPlayer.playerState.processingState == ProcessingState.completed) {
      await _audioPlayer.seek(Duration.zero);
      await _audioPlayer.play();
      return;
    }

    if (!_hasLoadedSource) {
      await _audioPlayer.setFilePath(_audioFile!.path);
      _duration = _audioPlayer.duration!;
      _hasLoadedSource = true;
    }
    await _audioPlayer.play();
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

  Future<void> _selectDate() async {
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

  Future<void> _addSong() async {
    if (_playerState == AppPlayerState.playing) {
      _audioPlayer.stop();
    }

    if (_isLoading) return;

    setState(() {
      _fieldErrors = {};
      _audioError = null;
      _imageError = null;
    });

    if (_audioFile == null) {
      setState(() => _audioError = 'Audio file is required');
    }

    if (!_formKey.currentState!.validate()) return;
    if (_audioError != null) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final song = await _songService.create(
        _nameController.text,
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

      if (song == null) return;

      bool imageSuccess = true;
      if (mounted && _imageFile != null) {
        imageSuccess = await _songService.setImage(
          song.id,
          _imageFile!,
          context,
        );
      }

      bool audioSuccess = false;
      if (mounted && _audioFile != null) {
        audioSuccess = await _songService.setAudio(
          song.id,
          _audioFile!,
          context,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _getSuccessMessage(imageSuccess, audioSuccess),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: imageSuccess && audioSuccess
                ? AppColors.greenAccent
                : AppColors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
        if (imageSuccess && audioSuccess) Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getSuccessMessage(bool imageSuccess, bool audioSuccess) {
    if (imageSuccess && audioSuccess) return "Song added successfully";
    List<String> errors = [];
    if (!imageSuccess) errors.add("image upload failed");
    if (!audioSuccess) errors.add("audio upload failed");
    return "Song created but ${errors.join(' and ')}";
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return [
      if (duration.inHours > 0) hours,
      minutes,
      seconds,
    ].join(':');
  }

  Widget _buildAudioUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _pickAudio,
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
                if (_audioFile != null) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _audioFile!.path.split('/').last,
                          style: const TextStyle(color: AppColors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _playerState == AppPlayerState.playing
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
                                  value: _dragValue ??
                                      _position.inSeconds.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      _dragValue = value;
                                    });
                                  },
                                  onChangeEnd: (value) async {
                                    final position =
                                        Duration(seconds: value.toInt());
                                    await _audioPlayer.seek(position);
                                    _dragValue = null;
                                  },
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
                              Text(
                                _formatDuration(_position),
                                style: const TextStyle(
                                  color: AppColors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(_duration),
                                style: const TextStyle(
                                  color: AppColors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    onPressed: () {
                      if (_playerState == AppPlayerState.playing) {
                        _audioPlayer.stop();
                      }
                      setState(() {
                        _audioFile = null;
                        _audioError = null;
                        _hasLoadedSource = false;
                      });
                    },
                  ),
                ] else
                  const Text(
                    'Audio file  (MP3)',
                    style: TextStyle(color: AppColors.white70),
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

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.1),
                  border: Border.all(color: AppColors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _imageFile!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40),
                          SizedBox(height: 8),
                          Text(
                            'Image\nJPG / JPEG',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ),
            ),
            if (_imageFile != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _imageFile = null),
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
        if (_imageError != null) const SizedBox(height: 16),
        if (_imageError != null)
          Text(
            _imageError!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  void _handleArtistSelection(List<LovResponse> selected) {
    setState(() => _selectedArtists = selected);
  }

  void _handleGenreSelection(List<LovResponse> selected) {
    setState(() => _selectedGenres = selected);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Add song"),
        drawer: const AdminAppDrawer(),
        endDrawer: const UserDrawer(),
        drawerScrimColor: Colors.black.withOpacity(0.4),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageUpload(),
                const SizedBox(height: 32),
                _buildAudioUpload(),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: _fieldErrors['Name'],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Song name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Release date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          errorText: _fieldErrors['DateOfRelease'],
                          suffixIcon: _selectedDate != null
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  onPressed: () =>
                                      setState(() => _selectedDate = null),
                                )
                              : const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                              : 'Select release date',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.white70,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Artists',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: _selectedArtists.map((artist) {
                            return Chip(
                              label: Text(artist.name),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              deleteIconColor: AppColors.grey,
                              onDeleted: () => setState(
                                  () => _selectedArtists.remove(artist)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.grey,
                                  width: 0.5,
                                ),
                              ),
                              backgroundColor: AppColors.background,
                            );
                          }).toList(),
                        ),
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
                                        builder: (context) => MultiSelectDialog(
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
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Genres',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: _selectedGenres.map((genre) {
                            return Chip(
                              label: Text(genre.name),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              deleteIconColor: AppColors.grey,
                              onDeleted: () =>
                                  setState(() => _selectedGenres.remove(genre)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(
                                  color: AppColors.grey,
                                  width: 0.5,
                                ),
                              ),
                              backgroundColor: AppColors.background,
                            );
                          }).toList(),
                        ),
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
                                        builder: (context) => MultiSelectDialog(
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
                    ),
                  ],
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addSong,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
