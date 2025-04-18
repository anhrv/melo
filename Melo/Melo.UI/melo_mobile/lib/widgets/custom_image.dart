import 'package:flutter/material.dart';
import 'package:melo_mobile/providers/auth_network_image.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class CustomImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;
  final IconData iconData;

  const CustomImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8.0,
    this.iconData = Icons.broken_image,
  });

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Image(
        width: widget.width,
        height: widget.height,
        image: AuthNetworkImage(widget.imageUrl),
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          if (!mounted) return const SizedBox.shrink();
          return _buildPlaceholder();
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) {
            if (!mounted) return const SizedBox.shrink();
            return _buildPlaceholder();
          }
          return child;
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.grey,
      child: Icon(widget.iconData),
    );
  }

  @override
  void dispose() {
    AuthNetworkImage.disposeClient();
    super.dispose();
  }
}
