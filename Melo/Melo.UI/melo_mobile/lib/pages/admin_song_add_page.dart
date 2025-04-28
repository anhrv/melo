import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/pages/admin_artist_add_page.dart';
import 'package:melo_mobile/pages/admin_genre_add_page.dart';
import 'package:melo_mobile/services/song_service.dart';
import 'package:melo_mobile/services/artist_service.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminSongAddPage extends StatefulWidget {
  const AdminSongAddPage({super.key});

  @override
  State<AdminSongAddPage> createState() => _AdminSongAddPageState();
}

class _AdminSongAddPageState extends State<AdminSongAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late SongService _songService;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;

  DateTime? _selectedDate;

  late ArtistService _artistService;
  List<LovResponse> _selectedArtists = [];

  late GenreService _genreService;
  List<LovResponse> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
    _songService = SongService(context);
    _artistService = ArtistService(context);
    _genreService = GenreService(context);
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
    if (_isLoading) return;
    setState(() {
      _fieldErrors = {};
    });

    if (!_formKey.currentState!.validate()) return;

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              imageSuccess
                  ? "Song added successfully"
                  : "Song created but image upload failed",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor:
                imageSuccess ? AppColors.greenAccent : AppColors.redAccent,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildImageUpload(),
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
