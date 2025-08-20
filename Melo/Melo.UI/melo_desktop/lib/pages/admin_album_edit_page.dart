import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/pages/admin_artist_add_page.dart';
import 'package:melo_desktop/pages/admin_artist_edit_page.dart';
import 'package:melo_desktop/pages/admin_genre_add_page.dart';
import 'package:melo_desktop/pages/admin_genre_edit_page.dart';
import 'package:melo_desktop/pages/admin_song_add_page.dart';
import 'package:melo_desktop/pages/admin_song_edit_page.dart';
import 'package:melo_desktop/services/album_service.dart';
import 'package:melo_desktop/services/artist_service.dart';
import 'package:melo_desktop/services/genre_service.dart';
import 'package:melo_desktop/services/song_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/toast_util.dart';
import 'package:melo_desktop/widgets/admin_side_menu.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/custom_image.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:melo_desktop/widgets/multi_select_dialog.dart';

class AdminAlbumEditPage extends StatefulWidget {
  final int albumId;
  final bool initialEditMode;

  const AdminAlbumEditPage({
    super.key,
    required this.albumId,
    this.initialEditMode = false,
  });

  @override
  State<AdminAlbumEditPage> createState() => _AdminAlbumEditPageState();
}

class _AdminAlbumEditPageState extends State<AdminAlbumEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late AlbumService _albumService;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;
  String? _songError;

  late SongService _songService;
  List<LovResponse> _selectedSongs = [];
  List<LovResponse> _originalSongs = [];

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

  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _albumService = AlbumService(context);
    _artistService = ArtistService(context);
    _genreService = GenreService(context);
    _songService = SongService(context);
    _isEditMode = widget.initialEditMode;
    _fetchAlbum();
  }

  Future<void> _fetchAlbum() async {
    setState(() => _isLoading = true);
    final album = await _albumService.getById(widget.albumId, context);
    if (album != null) {
      setState(() {
        originalName = album.name ?? "";
        originalImageUrl = album.imageUrl;
        viewCount = album.viewCount ?? 0;
        likeCount = album.likeCount ?? 0;
        playtime = album.playtime ?? "0:00";
        _originalDate = album.dateOfRelease != null
            ? DateTime.parse(album.dateOfRelease!)
            : null;
        _selectedDate = _originalDate;
        _selectedGenres = album.genres
            .map((g) => LovResponse(id: g.id, name: g.name ?? "No name"))
            .toList();
        _originalGenres = List.from(_selectedGenres);
        _selectedArtists = album.artists
            .map((a) => LovResponse(id: a.id, name: a.name ?? "No name"))
            .toList();
        _originalArtists = List.from(_selectedArtists);
        _selectedSongs = album.songs
            .map((s) => LovResponse(id: s.id, name: s.name ?? "No name"))
            .toList();
        _originalSongs = List.from(_selectedSongs);
        _nameController.text = originalName ?? "";
      });
    }
    setState(() => _isLoading = false);
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
    _formKey.currentState?.reset();
    setState(() {
      _isEditMode = false;
      _nameController.text = originalName ?? "";
      _imageFile = null;
      _isImageRemoved = false;
      _imageError = null;
      _songError = null;
      _fieldErrors = {};
      _selectedGenres = _originalGenres.toList();
      _selectedArtists = _originalArtists.toList();
      _selectedSongs = _originalSongs.toList();
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
    final songsChanged =
        !const ListEquality().equals(_selectedSongs, _originalSongs);

    final dateChanged = _selectedDate != _originalDate;

    return nameChanged ||
        imageChanged ||
        genresChanged ||
        artistsChanged ||
        songsChanged ||
        dateChanged;
  }

  Future<void> _saveChanges() async {
    if (_isLoading || !_hasChanges) return;

    setState(() {
      _fieldErrors = {};
      _songError = null;
      _imageError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
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
      final songsChanged =
          !const ListEquality().equals(_selectedSongs, _originalSongs);

      if (nameChanged ||
          dateChanged ||
          genresChanged ||
          artistsChanged ||
          songsChanged) {
        final updated = await _albumService.update(
          widget.albumId,
          newName,
          _selectedDate,
          _selectedArtists.isNotEmpty
              ? _selectedArtists.map((a) => a.id).toList()
              : null,
          _selectedGenres.isNotEmpty
              ? _selectedGenres.map((g) => g.id).toList()
              : null,
          _selectedSongs.isNotEmpty
              ? _selectedSongs.map((s) => s.id).toList()
              : null,
          context,
          (errors) => setState(() => _fieldErrors = errors),
        );
        if (updated == null) return;
        originalName = newName;
        _originalDate = _selectedDate;
        _originalGenres = _selectedGenres.toList();
        _originalArtists = _selectedArtists.toList();
        _originalSongs = _selectedSongs.toList();
      }

      if (imageChanged && mounted) {
        final success = await _albumService.setImage(
          widget.albumId,
          _isImageRemoved ? null : _imageFile,
          context,
        );
        if (!success && mounted) {
          ToastUtil.showToast('Failed to update image', true, context);
          return;
        }
        if (originalImageUrl != null) {
          final cacheManager = DefaultCacheManager();
          await cacheManager.removeFile(originalImageUrl!);
        }
      }

      await _fetchAlbum();
      _cancelEdit();

      if (mounted) {
        ToastUtil.showToast('Album updated successfully', false, context);
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
          borderRadius: BorderRadius.circular(8),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: Text(
                'Delete',
                style: TextStyle(
                  fontSize: 20,
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
        content: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 400),
          child: const Text(
            'Are you sure you want to delete this album? This action is permanent.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.white,
            ),
          ),
        ),
        backgroundColor: AppColors.backgroundLighter2,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.white,
                )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.white,
                )),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      final success = await _albumService.delete(widget.albumId, context);
      if (success && mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context, "deleted");
      }
    }
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
                width: 250,
                height: 250,
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
              fontSize: 14,
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
          width: 250,
          height: 250,
          color: AppColors.grey,
          child: const Icon(Icons.album, size: 40),
        ),
      );
    }

    return CustomImage(
      imageUrl: originalImageUrl!,
      width: 250,
      height: 250,
      borderRadius: 8,
      iconData: Icons.album,
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

  void _handleSongSelection(List<LovResponse> selected) {
    if (selected.isEmpty) {
      setState(() {
        _songError = "Album has to have at least one song";
      });
      return;
    }
    setState(() {
      _songError = null;
      _selectedSongs = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Album details"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Scrollbar(
                controller: _horizontalController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: Row(
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 12),
                                _buildImageUpload(),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 550),
                                  child: TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Name',
                                      errorText: _fieldErrors['Name'],
                                    ),
                                    readOnly: !_isEditMode,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Album name is required';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      if (_isEditMode) {
                                        setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 550),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Release date',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.white54,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _selectDate,
                                        child: InputDecorator(
                                          decoration: InputDecoration(
                                            errorText:
                                                _fieldErrors['DateOfRelease'],
                                            suffixIcon: _isEditMode &&
                                                    _selectedDate != null
                                                ? IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        size: 20),
                                                    onPressed: () => setState(
                                                        () => _selectedDate =
                                                            null),
                                                  )
                                                : _isEditMode
                                                    ? const Icon(
                                                        Icons.calendar_today)
                                                    : null,
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            _selectedDate != null
                                                ? DateFormat('dd MMM yyyy')
                                                    .format(_selectedDate!)
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
                                ),
                                const SizedBox(height: 10),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 550),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _selectedArtists.isEmpty &&
                                                  !_isEditMode
                                              ? const Text("No artists")
                                              : Wrap(
                                                  spacing: 8,
                                                  children: _selectedArtists
                                                      .map((artist) {
                                                    return GestureDetector(
                                                        onTap: _isEditMode
                                                            ? null
                                                            : () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        AdminSideMenuScaffold(
                                                                            body:
                                                                                AdminArtistEditPage(
                                                                              artistId: artist.id,
                                                                              initialEditMode: false,
                                                                            ),
                                                                            selectedIndex:
                                                                                -1),
                                                                  ),
                                                                );
                                                              },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 8,
                                                          ),
                                                          child: Chip(
                                                            label: Text(
                                                                artist.name),
                                                            deleteIcon: _isEditMode
                                                                ? const Icon(
                                                                    Icons.close,
                                                                    size: 18)
                                                                : null,
                                                            onDeleted: _isEditMode
                                                                ? () => setState(() =>
                                                                    _selectedArtists
                                                                        .remove(
                                                                            artist))
                                                                : null,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              side: BorderSide(
                                                                color: _isEditMode
                                                                    ? AppColors
                                                                        .white70
                                                                    : AppColors
                                                                        .secondary,
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                AppColors
                                                                    .background,
                                                            deleteIconColor:
                                                                AppColors.grey,
                                                            deleteButtonTooltipMessage:
                                                                "",
                                                          ),
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
                                                    size: 16,
                                                    color: AppColors.secondary,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: "Select artists",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.secondary,
                                                        fontSize: 16,
                                                      ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () async {
                                                              final selected =
                                                                  await showDialog<
                                                                      List<
                                                                          LovResponse>>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        MultiSelectDialog(
                                                                  fetchOptions: (searchTerm) =>
                                                                      _artistService.getLov(
                                                                          context,
                                                                          name:
                                                                              searchTerm),
                                                                  selected:
                                                                      _selectedArtists,
                                                                  addOptionPage:
                                                                      const AdminArtistAddPage(),
                                                                ),
                                                              );
                                                              if (selected !=
                                                                  null) {
                                                                _handleArtistSelection(
                                                                    selected);
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
                                ),
                              ],
                            ),
                            const SizedBox(width: 75),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 550),
                              child: Column(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          _selectedGenres.isEmpty &&
                                                  !_isEditMode
                                              ? const Text("No genres")
                                              : Wrap(
                                                  spacing: 8,
                                                  children: _selectedGenres
                                                      .map((genre) {
                                                    return GestureDetector(
                                                        onTap: _isEditMode
                                                            ? null
                                                            : () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        AdminSideMenuScaffold(
                                                                            body:
                                                                                AdminGenreEditPage(
                                                                              genreId: genre.id,
                                                                              initialEditMode: false,
                                                                            ),
                                                                            selectedIndex:
                                                                                -1),
                                                                  ),
                                                                );
                                                              },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                            top: 8,
                                                          ),
                                                          child: Chip(
                                                            label: Text(
                                                                genre.name),
                                                            deleteIcon: _isEditMode
                                                                ? const Icon(
                                                                    Icons.close,
                                                                    size: 18)
                                                                : null,
                                                            onDeleted: _isEditMode
                                                                ? () => setState(() =>
                                                                    _selectedGenres
                                                                        .remove(
                                                                            genre))
                                                                : null,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              side: BorderSide(
                                                                color: _isEditMode
                                                                    ? AppColors
                                                                        .white70
                                                                    : AppColors
                                                                        .secondary,
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                AppColors
                                                                    .background,
                                                            deleteIconColor:
                                                                AppColors.grey,
                                                            deleteButtonTooltipMessage:
                                                                "",
                                                          ),
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
                                                    size: 16,
                                                    color: AppColors.secondary,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(
                                                      text: "Select genres",
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.secondary,
                                                        fontSize: 16,
                                                      ),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () async {
                                                              final selected =
                                                                  await showDialog<
                                                                      List<
                                                                          LovResponse>>(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        MultiSelectDialog(
                                                                  fetchOptions: (searchTerm) =>
                                                                      _genreService.getLov(
                                                                          context,
                                                                          name:
                                                                              searchTerm),
                                                                  selected:
                                                                      _selectedGenres,
                                                                  addOptionPage:
                                                                      const AdminGenreAddPage(),
                                                                ),
                                                              );
                                                              if (selected !=
                                                                  null) {
                                                                _handleGenreSelection(
                                                                    selected);
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
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 550),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Songs',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.white54,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            if (_selectedSongs.isEmpty &&
                                                !_isEditMode)
                                              const Text("No songs")
                                            else if (_selectedSongs.isNotEmpty)
                                              ScrollConfiguration(
                                                behavior:
                                                    ScrollConfiguration.of(
                                                            context)
                                                        .copyWith(
                                                  dragDevices: {
                                                    PointerDeviceKind.touch,
                                                    PointerDeviceKind.mouse,
                                                  },
                                                ),
                                                child:
                                                    ReorderableListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      _selectedSongs.length,
                                                  onReorder:
                                                      (oldIndex, newIndex) {
                                                    setState(() {
                                                      if (oldIndex < newIndex)
                                                        newIndex--;
                                                      final item =
                                                          _selectedSongs
                                                              .removeAt(
                                                                  oldIndex);
                                                      _selectedSongs.insert(
                                                          newIndex, item);
                                                    });
                                                  },
                                                  buildDefaultDragHandles:
                                                      false,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final song =
                                                        _selectedSongs[index];
                                                    return GestureDetector(
                                                      key: ValueKey(song.id),
                                                      onTap: _isEditMode
                                                          ? null
                                                          : () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) =>
                                                                      AdminSideMenuScaffold(
                                                                          body:
                                                                              AdminSongEditPage(
                                                                            songId:
                                                                                song.id,
                                                                            initialEditMode:
                                                                                false,
                                                                          ),
                                                                          selectedIndex:
                                                                              -1),
                                                                ),
                                                              );
                                                            },
                                                      child: Card(
                                                        key: ValueKey(song.id),
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 4),
                                                        color: AppColors
                                                            .background,
                                                        surfaceTintColor:
                                                            Colors.transparent,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          side: BorderSide(
                                                            color: _isEditMode
                                                                ? AppColors.grey
                                                                : AppColors
                                                                    .secondary,
                                                            width: 0.5,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Row(
                                                            children: [
                                                              if (_isEditMode) ...[
                                                                ReorderableDragStartListener(
                                                                  index: index,
                                                                  child:
                                                                      const MouseRegion(
                                                                    cursor:
                                                                        SystemMouseCursors
                                                                            .grab,
                                                                    child: Icon(
                                                                      Icons
                                                                          .drag_handle,
                                                                      size: 20,
                                                                      color: AppColors
                                                                          .white54,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                              ],
                                                              Text(
                                                                '${index + 1}.',
                                                                style:
                                                                    const TextStyle(
                                                                  color: AppColors
                                                                      .white54,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 12),
                                                              Expanded(
                                                                child: Text(
                                                                  song.name,
                                                                  style:
                                                                      const TextStyle(
                                                                    color: AppColors
                                                                        .white,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                              _isEditMode &&
                                                                      _selectedSongs
                                                                              .length >
                                                                          1
                                                                  ? IconButton(
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .close,
                                                                        size:
                                                                            18,
                                                                        color: AppColors
                                                                            .grey,
                                                                      ),
                                                                      onPressed: () =>
                                                                          setState(() =>
                                                                              _selectedSongs.removeAt(index)),
                                                                    )
                                                                  : const SizedBox(
                                                                      width: 48,
                                                                      height:
                                                                          48,
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            if (_songError != null) ...[
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  _songError!,
                                                  style: const TextStyle(
                                                    color: Colors.redAccent,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            if (_isEditMode) ...[
                                              const SizedBox(height: 12),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.add,
                                                      size: 16,
                                                      color:
                                                          AppColors.secondary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    RichText(
                                                      text: TextSpan(
                                                        text: "Select songs",
                                                        style: const TextStyle(
                                                          color: AppColors
                                                              .secondary,
                                                          fontSize: 16,
                                                        ),
                                                        recognizer:
                                                            TapGestureRecognizer()
                                                              ..onTap =
                                                                  () async {
                                                                final selected =
                                                                    await showDialog<
                                                                        List<
                                                                            LovResponse>>(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) =>
                                                                          MultiSelectDialog(
                                                                    fetchOptions: (searchTerm) => _songService.getLov(
                                                                        context,
                                                                        name:
                                                                            searchTerm),
                                                                    selected:
                                                                        _selectedSongs,
                                                                    addOptionPage:
                                                                        const AdminSongAddPage(),
                                                                  ),
                                                                );
                                                                if (selected !=
                                                                    null) {
                                                                  _handleSongSelection(
                                                                      selected);
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
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!_isEditMode) ...[
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Playtime: ${playtime ?? "0:00"}',
                              style: const TextStyle(
                                fontSize: 16,
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
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 24),
                            const Icon(Icons.thumb_up,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Likes: ${likeCount ?? 0}',
                              style: const TextStyle(
                                fontSize: 16,
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
          ),
        ),
      ),
    );
  }

  Widget _buildViewButtons() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                onPressed: () => setState(() => _isEditMode = true),
                child: const Text('Edit'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                onPressed: _confirmDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAccent,
                ),
                child: const Text('Delete'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButtons() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                onPressed: _hasChanges ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _hasChanges ? null : AppColors.grey.withOpacity(0.5),
                ),
                child: const Text('Save'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 40,
              child: ElevatedButton(
                onPressed: _cancelEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.grey,
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
