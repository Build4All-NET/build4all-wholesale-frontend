import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/uploaded_image_url_resolver.dart';

class RetailerProductImage extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final double borderRadius;
  final double iconSize;
  final BoxFit fit;
  final EdgeInsetsGeometry imagePadding;

  const RetailerProductImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.borderRadius = 16,
    this.iconSize = 36,
    this.fit = BoxFit.contain,
    this.imagePadding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = UploadedImageUrlResolver.resolve(imageUrl);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
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
          : Padding(
              padding: imagePadding,
              child: Image.network(
                resolvedUrl,
                fit: fit,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.inventory_2_outlined,
                    color: AppThemeTokens.textSecondary,
                    size: iconSize,
                  );
                },
              ),
            ),
    );
  }
}
