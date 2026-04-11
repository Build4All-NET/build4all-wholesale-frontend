import 'package:flutter/material.dart';

import '../../../../injection_container.dart';
import '../../../../core/theme/theme_cubit.dart';

class DashboardScreen extends StatelessWidget {
  final String? title;

  const DashboardScreen({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title ?? 'Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Dashboard Placeholder',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                sl<ThemeCubit>().updateSeedColor(
                  const Color(0xFF16A34A),
                );
              },
              child: const Text('Green Theme'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                sl<ThemeCubit>().updateSeedColor(
                  const Color(0xFF2563EB),
                );
              },
              child: const Text('Blue Theme'),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: () {
                sl<ThemeCubit>().updateSeedColor(
                  const Color(0xFFF97316),
                );
              },
              child: const Text('Orange Theme'),
            ),
          ],
        ),
      ),
    );
  }
}