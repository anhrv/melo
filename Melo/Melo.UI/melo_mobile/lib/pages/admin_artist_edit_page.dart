import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/pages/admin_genre_add_page.dart';
import 'package:melo_mobile/pages/admin_genre_edit_page.dart';
import 'package:melo_mobile/services/artist_service.dart';
import 'package:melo_mobile/services/genre_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/admin_app_drawer.dart';
import 'package:melo_mobile/widgets/app_bar.dart';
import 'package:melo_mobile/widgets/custom_image.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';
import 'package:melo_mobile/widgets/multi_select_dialog.dart';
import 'package:melo_mobile/widgets/user_drawer.dart';

class AdminArtistEditPage extends StatefulWidget {
  final int artistId;
  final bool initialEditMode;

  const AdminArtistEditPage({
    super.key,
    required this.artistId,
    this.initialEditMode = false,
  });

  @override
  State<AdminArtistEditPage> createState() => _AdminArtistEditPageState();
}

class _AdminArtistEditPageState extends State<AdminArtistEditPage> {
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
  List<LovResponse> _originalGenres = [];

  String? originalName;
  String? originalImageUrl;
  int? viewCount;
  int? likeCount;

  bool _isImageRemoved = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _artistService = ArtistService(context);
    _genreService = GenreService(context);
    _isEditMode = widget.initialEditMode;
    _fetchArtist();
  }

  Future<void> _fetchArtist() async {
    setState(() => _isLoading = true);
    final artist = await _artistService.getById(widget.artistId, context);
    if (artist != null) {
      setState(() {
        originalName = artist.name ?? "";
        originalImageUrl = artist.imageUrl;
        viewCount = artist.viewCount ?? 0;
        likeCount = artist.likeCount ?? 0;
        _selectedGenres = artist.genres
            .map((g) => LovResponse(id: g.id, name: g.name ?? "No name"))
            .toList();
        _originalGenres = List.from(_selectedGenres);
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
      _fieldErrors = {};
      _selectedGenres = _originalGenres.toList();
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
    return nameChanged || imageChanged || genresChanged;
  }

  Future<void> _saveChanges() async {
    if (_isLoading || !_hasChanges) return;

    setState(() {
      _fieldErrors = {};
      _imageError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final newName = _nameController.text;
      bool nameChanged = newName != originalName;
      bool imageChanged = _imageFile != null || _isImageRemoved;
      bool genresChanged = !const SetEquality()
          .equals(_selectedGenres.toSet(), _originalGenres.toSet());

      if (nameChanged || genresChanged) {
        final updated = await _artistService.update(
          widget.artistId,
          newName,
          _selectedGenres.isNotEmpty
              ? _selectedGenres.map((g) => g.id).toList()
              : null,
          context,
          (errors) => setState(() => _fieldErrors = errors),
        );
        if (updated == null) return;
        originalName = newName;
        _originalGenres = _selectedGenres.toList();
      }

      if (imageChanged && mounted) {
        final success = await _artistService.setImage(
          widget.artistId,
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
          return;
        }
        if (originalImageUrl != null) {
          final cacheManager = DefaultCacheManager();
          await cacheManager.removeFile(originalImageUrl!);
        }
      }

      await _fetchArtist();
      _cancelEdit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Artist updated successfully',
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
          'Are you sure you want to delete this artist? This action is permanent.',
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
      final success = await _artistService.delete(widget.artistId, context);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Artist deleted successfully",
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
          child: const Icon(Icons.mic, size: 40),
        ),
      );
    }

    return CustomImage(
      imageUrl: originalImageUrl!,
      width: 150,
      height: 150,
      borderRadius: 8,
      iconData: Icons.mic,
    );
  }

  bool get _shouldShowCloseButton {
    return _isEditMode &&
        (_imageFile != null || (!_isImageRemoved && originalImageUrl != null));
  }

  void _handleGenreSelection(List<LovResponse> selected) {
    setState(() => _selectedGenres = selected);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Artist details"),
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
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    errorText: _fieldErrors['Name'],
                  ),
                  readOnly: !_isEditMode,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Artist name is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_isEditMode) {
                      setState(() {});
                    }
                  },
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
