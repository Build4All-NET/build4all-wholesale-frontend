class BrandingState {
  final String appName;
  final String logoUrl;
  final String logoAsset;
  final bool isLoaded;

  const BrandingState({
    required this.appName,
    required this.logoUrl,
    required this.logoAsset,
    required this.isLoaded,
  });

  BrandingState copyWith({
    String? appName,
    String? logoUrl,
    String? logoAsset,
    bool? isLoaded,
  }) {
    return BrandingState(
      appName: appName ?? this.appName,
      logoUrl: logoUrl ?? this.logoUrl,
      logoAsset: logoAsset ?? this.logoAsset,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}
