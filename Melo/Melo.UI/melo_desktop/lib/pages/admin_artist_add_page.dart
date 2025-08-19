import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/pages/admin_genre_add_page.dart';
import 'package:melo_desktop/services/artist_service.dart';
import 'package:melo_desktop/services/genre_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';
import 'package:melo_desktop/widgets/multi_select_dialog.dart';

class AdminArtistAddPage extends StatefulWidget {
  const AdminArtistAddPage({super.key});

  @override
  State<AdminArtistAddPage> createState() => _AdminArtistAddPageState();
}

class _AdminArtistAddPageState extends State<AdminArtistAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late ArtistService _artistService;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;

  late GenreService _genreService;
  List<LovResponse> _selectedGenres = [];

  @override
  void initState() {
    super.initState();
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

  Future<void> _addArtist() async {
    if (_isLoading) return;

    setState(() {
      _fieldErrors = {};
      _imageError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final artist = await _artistService.create(
        _nameController.text,
        _selectedGenres.isNotEmpty
            ? _selectedGenres.map((g) => g.id).toList()
            : null,
        context,
        (errors) => setState(() => _fieldErrors = errors),
      );

      if (artist == null) return;

      bool imageSuccess = true;
      if (mounted && _imageFile != null) {
        imageSuccess = await _artistService.setImage(
          artist.id,
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
                width: 300,
                height: 300,
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

  void _handleGenreSelection(List<LovResponse> selected) {
    setState(() => _selectedGenres = selected);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Add artist"),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  _buildImageUpload(),
                  const SizedBox(height: 24),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        errorText: _fieldErrors['Name'],
                      ),
                      textAlign: TextAlign.center,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Artist name is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
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
                                return Container(
                                  padding: EdgeInsets.only(
                                    top: 8,
                                  ),
                                  child: Chip(
                                    label: Text(genre.name),
                                    deleteIcon:
                                        const Icon(Icons.close, size: 18),
                                    deleteIconColor: AppColors.grey,
                                    onDeleted: () => setState(
                                        () => _selectedGenres.remove(genre)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: AppColors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                    backgroundColor: AppColors.background,
                                    deleteButtonTooltipMessage: "",
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
                                        color: AppColors.secondary,
                                        fontSize: 16,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () async {
                                          final selected = await showDialog<
                                              List<LovResponse>>(
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 58),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _addArtist,
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
    );
  }
}
