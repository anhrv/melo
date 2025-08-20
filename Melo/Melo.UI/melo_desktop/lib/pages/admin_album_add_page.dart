import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/pages/admin_artist_add_page.dart';
import 'package:melo_desktop/pages/admin_genre_add_page.dart';
import 'package:melo_desktop/pages/admin_song_add_page.dart';
import 'package:melo_desktop/services/album_service.dart';
import 'package:melo_desktop/services/artist_service.dart';
import 'package:melo_desktop/services/genre_service.dart';
import 'package:melo_desktop/services/song_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:melo_desktop/widgets/multi_select_dialog.dart';

class AdminAlbumAddPage extends StatefulWidget {
  const AdminAlbumAddPage({super.key});

  @override
  State<AdminAlbumAddPage> createState() => _AdminAlbumAddPageState();
}

class _AdminAlbumAddPageState extends State<AdminAlbumAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late AlbumService _albumService;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;
  String? _songError;

  DateTime? _selectedDate;

  late ArtistService _artistService;
  List<LovResponse> _selectedArtists = [];

  late GenreService _genreService;
  List<LovResponse> _selectedGenres = [];

  late SongService _songService;
  List<LovResponse> _selectedSongs = [];

  final ScrollController _horizontalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _albumService = AlbumService(context);
    _artistService = ArtistService(context);
    _genreService = GenreService(context);
    _songService = SongService(context);
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

  Future<void> _addAlbum() async {
    if (_isLoading) return;

    setState(() {
      _fieldErrors = {};
      _songError = null;
      _imageError = null;
    });

    if (_selectedSongs.isEmpty) {
      setState(() {
        _songError = "Album has to have at least one song";
      });
    }

    if (!_formKey.currentState!.validate()) return;
    if (_songError != null) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final album = await _albumService.create(
        _nameController.text,
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

      if (album == null) return;

      bool imageSuccess = true;
      if (mounted && _imageFile != null) {
        imageSuccess = await _albumService.setImage(
          album.id,
          _imageFile!,
          context,
        );
      }

      if (mounted) {
        Navigator.pop(context, imageSuccess ? "success" : "partial");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                width: 250,
                height: 250,
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
              fontSize: 14,
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

  void _handleSongSelection(List<LovResponse> selected) {
    if (selected.isEmpty) {
      setState(() => _songError = "Album has to have at least one song");
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
        appBar: const CustomAppBar(title: "Add album"),
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Album name is required';
                                      }
                                      return null;
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
                                          fontSize: 16,
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
                                            suffixIcon: _selectedDate != null
                                                ? IconButton(
                                                    icon: const Icon(
                                                        Icons.close,
                                                        size: 20),
                                                    onPressed: () => setState(
                                                        () => _selectedDate =
                                                            null),
                                                  )
                                                : const Icon(
                                                    Icons.calendar_today),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            _selectedDate != null
                                                ? DateFormat('dd MMM yyyy')
                                                    .format(_selectedDate!)
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
                                ),
                                const SizedBox(height: 14),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Wrap(
                                            spacing: 8,
                                            children:
                                                _selectedArtists.map((artist) {
                                              return Container(
                                                padding: EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Chip(
                                                  label: Text(artist.name),
                                                  deleteIcon: const Icon(
                                                      Icons.close,
                                                      size: 18),
                                                  deleteIconColor:
                                                      AppColors.grey,
                                                  onDeleted: () => setState(
                                                      () => _selectedArtists
                                                          .remove(artist)),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    side: const BorderSide(
                                                      color: AppColors.grey,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.background,
                                                  deleteButtonTooltipMessage:
                                                      "",
                                                ),
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
                                                              context: context,
                                                              builder: (context) =>
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
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 75),
                            Column(
                              children: [
                                const SizedBox(height: 12),
                                const SizedBox(height: 14),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 550),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Wrap(
                                            spacing: 8,
                                            children:
                                                _selectedGenres.map((genre) {
                                              return Container(
                                                padding: EdgeInsets.only(
                                                  top: 8,
                                                ),
                                                child: Chip(
                                                  label: Text(genre.name),
                                                  deleteIcon: const Icon(
                                                      Icons.close,
                                                      size: 18),
                                                  deleteIconColor:
                                                      AppColors.grey,
                                                  onDeleted: () => setState(
                                                      () => _selectedGenres
                                                          .remove(genre)),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    side: const BorderSide(
                                                      color: AppColors.grey,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      AppColors.background,
                                                  deleteButtonTooltipMessage:
                                                      "",
                                                ),
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
                                                              context: context,
                                                              builder: (context) =>
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
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),
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
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.white54,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          if (_selectedSongs.isNotEmpty)
                                            ScrollConfiguration(
                                              behavior: ScrollConfiguration.of(
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
                                                    final item = _selectedSongs
                                                        .removeAt(oldIndex);
                                                    _selectedSongs.insert(
                                                        newIndex, item);
                                                  });
                                                },
                                                buildDefaultDragHandles: false,
                                                itemBuilder: (context, index) {
                                                  final song =
                                                      _selectedSongs[index];
                                                  return Card(
                                                    key: ValueKey(song.id),
                                                    margin: const EdgeInsets
                                                        .symmetric(vertical: 4),
                                                    color: AppColors.background,
                                                    surfaceTintColor:
                                                        Colors.transparent,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      side: const BorderSide(
                                                        color: AppColors.grey,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                      child: Row(
                                                        children: [
                                                          ReorderableDragStartListener(
                                                            index: index,
                                                            child: MouseRegion(
                                                              cursor:
                                                                  SystemMouseCursors
                                                                      .grab,
                                                              child:
                                                                  GestureDetector(
                                                                behavior:
                                                                    HitTestBehavior
                                                                        .translucent,
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .drag_handle,
                                                                      size: 20,
                                                                      color: AppColors
                                                                          .white54,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      '${index + 1}.',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: AppColors
                                                                            .white54,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
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
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ),
                                                          _selectedSongs
                                                                      .length >
                                                                  1
                                                              ? IconButton(
                                                                  icon:
                                                                      const Icon(
                                                                    Icons.close,
                                                                    size: 18,
                                                                    color:
                                                                        AppColors
                                                                            .grey,
                                                                  ),
                                                                  onPressed: () =>
                                                                      setState(() =>
                                                                          _selectedSongs
                                                                              .removeAt(index)),
                                                                )
                                                              : const SizedBox(
                                                                  width: 48,
                                                                  height: 48,
                                                                ),
                                                        ],
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
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.add,
                                                  size: 16,
                                                  color: AppColors.secondary,
                                                ),
                                                const SizedBox(width: 4),
                                                RichText(
                                                  text: TextSpan(
                                                    text: "Select songs",
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
                                                              context: context,
                                                              builder: (context) =>
                                                                  MultiSelectDialog(
                                                                fetchOptions: (searchTerm) =>
                                                                    _songService.getLov(
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
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 350),
                        child: SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _addAlbum,
                            child: const Text('Add'),
                          ),
                        ),
                      ),
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
}
