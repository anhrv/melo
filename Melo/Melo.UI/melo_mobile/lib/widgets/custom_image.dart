import 'package:flutter/material.dart';
import 'package:melo_mobile/providers/image_provider.dart';
import 'package:melo_mobile/themes/app_colors.dart';

class CustomImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final double borderRadius;
  final IconData iconData;

  const CustomImage(
      {super.key,
      required this.imageUrl,
      required this.width,
      required this.height,
      this.fit = BoxFit.cover,
      this.borderRadius = 8.0,
      this.iconData = Icons.broken_image});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image(
        width: width,
        height: height,
        image: AuthNetworkImage(imageUrl, context),
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (frame == null) return _buildPlaceholder();
          return child;
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.grey,
      child: Icon(iconData),
    );
  }
}
