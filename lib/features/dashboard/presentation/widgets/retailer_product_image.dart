import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/uploaded_image_url_resolver.dart';

class RetailerProductImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final double iconSize;

  const RetailerProductImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.iconSize = 36,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = UploadedImageUrlResolver.resolve(imageUrl);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppThemeTokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: resolvedUrl == null
          ? Icon(
              Icons.inventory_2_outlined,
              color: AppThemeTokens.textSecondary,
              size: iconSize,
            )
          : Image.network(
              resolvedUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.inventory_2_outlined,
                  color: AppThemeTokens.textSecondary,
                  size: iconSize,
                );
              },
            ),
    );
  }
}
