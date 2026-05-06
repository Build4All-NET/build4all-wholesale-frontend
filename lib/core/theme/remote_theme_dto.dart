import 'dart:convert';

class RemoteThemeDto {
  final String? menuType;
  final Map<String, dynamic> valuesMobile;

  const RemoteThemeDto({required this.menuType, required this.valuesMobile});

  factory RemoteThemeDto.fromJson(Map<String, dynamic> json) {
    final valuesMobileRaw = json['valuesMobile'];

    return RemoteThemeDto(
      menuType: json['menuType']?.toString(),
      valuesMobile: valuesMobileRaw is Map<String, dynamic>
          ? valuesMobileRaw
          : const {},
    );
  }

  factory RemoteThemeDto.fromBase64Json(String value) {
    if (value.trim().isEmpty) {
      return const RemoteThemeDto(menuType: null, valuesMobile: {});
    }

    final decodedText = utf8.decode(base64Decode(value.trim()));
    final decodedJson = jsonDecode(decodedText);

    if (decodedJson is! Map<String, dynamic>) {
      return const RemoteThemeDto(menuType: null, valuesMobile: {});
    }

    return RemoteThemeDto.fromJson(decodedJson);
  }

  factory RemoteThemeDto.fromJsonString(String value) {
    if (value.trim().isEmpty) {
      return const RemoteThemeDto(menuType: null, valuesMobile: {});
    }

    final decodedJson = jsonDecode(value.trim());

    if (decodedJson is! Map<String, dynamic>) {
      return const RemoteThemeDto(menuType: null, valuesMobile: {});
    }

    return RemoteThemeDto.fromJson(decodedJson);
  }
}
