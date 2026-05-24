import 'package:flutter/material.dart';
import 'package:build4all_wholesale_frontend/core/extensions/l10n_extension.dart';

import '../../../../../core/theme/app_theme_tokens.dart';
import '../../domain/entities/supplier_profile_display_entity.dart';

class SupplierProfileHeaderCard extends StatelessWidget {
  final SupplierProfileDisplayEntity profile;

  SupplierProfileHeaderCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(AppThemeTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: primary.withOpacity(0.18),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.white.withOpacity(0.18),
            child: Text(
              _initials(profile),
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(height: 14),
          Text(
            _displayName(context, profile),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            _clean(context, profile.email),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.22),
              ),
            ),
            child: Text(
              _roleLabel(context, profile.role),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }


  String _displayName(BuildContext context, SupplierProfileDisplayEntity profile) {
    final first = profile.firstName?.trim() ?? '';
    final last = profile.lastName?.trim() ?? '';
    final fullName = '$first $last'.trim();

    if (fullName.isNotEmpty) return fullName;
    if ((profile.username ?? '').trim().isNotEmpty) return profile.username!.trim();
    if ((profile.email ?? '').trim().isNotEmpty) return profile.email!.trim();

    return context.l10n.supplierManager;
  }

  String _roleLabel(BuildContext context, String? role) {
    final value = role?.trim();

    if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
      return context.l10n.supplierNotProvided;
    }

    switch (value.toUpperCase()) {
      case 'OWNER':
      case 'SUPPLIER':
        return context.l10n.supplierOwnerLabel;
      default:
        return value;
    }
  }

  String _initials(SupplierProfileDisplayEntity profile) {
    final first = profile.firstName?.trim();
    final last = profile.lastName?.trim();

    if (first != null && first.isNotEmpty && last != null && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }

    final name = profile.fullName.trim();
    if (name.isEmpty) return 'S';

    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }

    return name[0].toUpperCase();
  }

  String _clean(BuildContext context, String? value) {
    final text = value?.trim();
    if (text == null || text.isEmpty) return context.l10n.supplierNotProvided;
    return text;
  }
}
