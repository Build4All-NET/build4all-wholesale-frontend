import 'package:flutter/material.dart';

import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme_tokens.dart';
import '../../../../core/utils/uploaded_image_url_resolver.dart';
import '../../data/models/retailer_home_model.dart';

class HomeBannerSection extends StatelessWidget {
  final List<HomeBannerModel> banners;
  final void Function(HomeBannerModel banner) onBannerTap;

  const HomeBannerSection({
    super.key,
    required this.banners,
    required this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 172,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.93),
        itemCount: banners.length,
        itemBuilder: (context, index) {
          final banner = banners[index];

          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 10),
            child: _HomeBannerCard(
              banner: banner,
              onTap: () => onBannerTap(banner),
            ),
          );
        },
      ),
    );
  }
}

class _HomeBannerCard extends StatelessWidget {
  final HomeBannerModel banner;
  final VoidCallback onTap;

  const _HomeBannerCard({required this.banner, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final imageUrl = UploadedImageUrlResolver.resolve(banner.imageUrl);
    final startColor = _parseColor(banner.backgroundColorStart, primaryColor);
    final endColor = _parseColor(banner.backgroundColorEnd, primaryColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: primaryColor,
            gradient: imageUrl == null
                ? LinearGradient(
                    colors: [startColor, endColor],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  )
                : null,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (imageUrl != null)
                Positioned.fill(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(
                          alpha: imageUrl == null ? 0.88 : 0.94,
                        ),
                        primaryColor.withValues(
                          alpha: imageUrl == null ? 0.70 : 0.46,
                        ),
                      ],
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            banner.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                            ),
                          ),
                          if (banner.subtitle.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              banner.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                height: 1.30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const Spacer(),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppThemeTokens.textPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                banner.ctaLabel.trim().isEmpty
                                    ? context.l10n.viewAvailableDeals
                                    : banner.ctaLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.local_offer_outlined,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.trim().isEmpty) {
      return fallback;
    }

    final cleaned = hex.replaceAll('#', '').trim();

    if (cleaned.length != 6) {
      return fallback;
    }

    final value = int.tryParse('FF$cleaned', radix: 16);

    return value == null ? fallback : Color(value);
  }
}
