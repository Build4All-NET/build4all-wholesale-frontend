import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'branding_cubit.dart';
import 'branding_state.dart';

class AppBrandLogo extends StatelessWidget {
  final double size;
  final double iconSize;
  final IconData fallbackIcon;
  final Color? fallbackIconColor;
  final Color? backgroundColor;
  final BoxFit fit;
  final EdgeInsetsGeometry padding;

  const AppBrandLogo({
    super.key,
    this.size = 82,
    this.iconSize = 38,
    this.fallbackIcon = Icons.storefront_outlined,
    this.fallbackIconColor,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.padding = const EdgeInsets.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return BlocBuilder<BrandingCubit, BrandingState>(
      builder: (context, state) {
        final logoUrl = state.logoUrl.toString().trim();
        final logoAsset = state.logoAsset.toString().trim();

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: padding,
            child: _buildLogo(
              logoUrl: logoUrl,
              logoAsset: logoAsset,
              fallbackColor: fallbackIconColor ?? primary,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo({
    required String logoUrl,
    required String logoAsset,
    required Color fallbackColor,
  }) {
    if (logoUrl.isNotEmpty) {
      return Image.network(
        logoUrl,
        fit: fit,
        errorBuilder: (_, _, _) => _assetOrIcon(logoAsset, fallbackColor),
      );
    }

    return _assetOrIcon(logoAsset, fallbackColor);
  }

  Widget _assetOrIcon(String logoAsset, Color fallbackColor) {
    if (logoAsset.isNotEmpty) {
      return Image.asset(
        logoAsset,
        fit: fit,
        errorBuilder: (_, _, _) => _fallbackIcon(fallbackColor),
      );
    }

    return _fallbackIcon(fallbackColor);
  }

  Widget _fallbackIcon(Color color) {
    return Icon(
      fallbackIcon,
      size: iconSize,
      color: color,
    );
  }
}
