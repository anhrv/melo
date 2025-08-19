import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:melo_desktop/services/genre_service.dart';
import 'package:melo_desktop/themes/app_colors.dart';
import 'package:melo_desktop/utils/toast_util.dart';
import 'package:melo_desktop/widgets/app_bar.dart';
import 'package:melo_desktop/widgets/custom_image.dart';
import 'package:melo_desktop/widgets/loading_overlay.dart';

class AdminGenreEditPage extends StatefulWidget {
  final int genreId;
  final bool initialEditMode;

  const AdminGenreEditPage({
    super.key,
    required this.genreId,
    this.initialEditMode = false,
  });

  @override
  State<AdminGenreEditPage> createState() => _AdminGenreEditPageState();
}

class _AdminGenreEditPageState extends State<AdminGenreEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  Map<String, String> _fieldErrors = {};
  late GenreService _genreService;
  final ImagePicker _picker = ImagePicker();
  String? _imageError;

  String? originalName;
  String? originalImageUrl;
  int? viewCount;
  bool _isImageRemoved = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _genreService = GenreService(context);
    _isEditMode = widget.initialEditMode;
    _fetchGenre();
  }

  Future<void> _fetchGenre() async {
    setState(() => _isLoading = true);
    final genre = await _genreService.getById(widget.genreId, context);
    if (genre != null) {
      setState(() {
        originalName = genre.name ?? "";
        originalImageUrl = genre.imageUrl;
        viewCount = genre.viewCount ?? 0;
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
    return nameChanged || imageChanged;
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

      if (nameChanged) {
        final updated = await _genreService.update(
          widget.genreId,
          newName,
          context,
          (errors) => setState(() => _fieldErrors = errors),
        );
        if (updated == null) return;
        originalName = newName;
      }

      if (imageChanged && mounted) {
        final success = await _genreService.setImage(
          widget.genreId,
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

      await _fetchGenre();
      _cancelEdit();

      if (mounted) {
        ToastUtil.showToast('Genre updated successfully', false, context);
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
          constraints: const BoxConstraints(
            minWidth: 400,
          ),
          child: const Text(
            'Are you sure you want to delete this genre? This action is permanent.',
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
      final success = await _genreService.delete(widget.genreId, context);
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
                width: 300,
                height: 300,
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
          width: 300,
          height: 300,
          color: AppColors.grey,
          child: const Icon(Icons.type_specimen, size: 40),
        ),
      );
    }

    return CustomImage(
      imageUrl: originalImageUrl!,
      width: 300,
      height: 300,
      borderRadius: 8,
      iconData: Icons.type_specimen,
    );
  }

  bool get _shouldShowCloseButton {
    return _isEditMode &&
        (_imageFile != null || (!_isImageRemoved && originalImageUrl != null));
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Genre details"),
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
                      readOnly: !_isEditMode,
                      textAlign: TextAlign.center,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Genre name is required';
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
                  if (!_isEditMode) ...[
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                      ],
                    ),
                  ],
                  const SizedBox(height: 48),
                  _isEditMode ? _buildEditButtons() : _buildViewButtons(),
                ],
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
    return ConstrainedBox(
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
