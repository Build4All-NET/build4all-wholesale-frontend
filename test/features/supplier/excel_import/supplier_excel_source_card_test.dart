import 'package:build4all_wholesale_frontend/features/supplier/excel_import/presentation/bloc/supplier_excel_import_state.dart';
import 'package:build4all_wholesale_frontend/features/supplier/excel_import/presentation/utils/supplier_excel_import_i18n.dart';
import 'package:build4all_wholesale_frontend/features/supplier/excel_import/presentation/widgets/supplier_excel_source_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A store without AI is offered the Build4All template and nothing else:
/// reading a file from another system and photographing products are AI
/// features and must not even be listed.
void main() {
  late SupplierExcelImportI18n l;

  Future<void> pump(
    WidgetTester tester, {
    required bool aiEnabled,
    required bool photosAvailable,
    ValueChanged<SupplierExcelSource>? onChanged,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              l = SupplierExcelImportI18n(context);
              return SupplierExcelSourceCard(
                source: null,
                aiEnabled: aiEnabled,
                photosAvailable: photosAvailable,
                onChanged: onChanged ?? (_) {},
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('offers only the template when the store has no AI', (tester) async {
    await pump(tester, aiEnabled: false, photosAvailable: false);

    expect(find.text(l.sourceFileTitle), findsOneWidget);
    expect(find.text(l.sourceForeignTitle), findsNothing);
    expect(find.text(l.sourcePhotosTitle), findsNothing);
  });

  /// The server can say photos are available (a model is configured) while the
  /// store's plan has no AI; the plan wins.
  testWidgets('hides photographing when the store has no AI even if a model exists', (tester) async {
    await pump(tester, aiEnabled: false, photosAvailable: true);

    expect(find.text(l.sourceFileTitle), findsOneWidget);
    expect(find.text(l.sourceForeignTitle), findsNothing);
    expect(find.text(l.sourcePhotosTitle), findsNothing);
  });

  testWidgets('offers the foreign file when the store has AI', (tester) async {
    await pump(tester, aiEnabled: true, photosAvailable: false);

    expect(find.text(l.sourceFileTitle), findsOneWidget);
    expect(find.text(l.sourceForeignTitle), findsOneWidget);
    expect(find.text(l.sourcePhotosTitle), findsNothing);
  });

  testWidgets('offers photographing only when the store has AI and a model', (tester) async {
    await pump(tester, aiEnabled: true, photosAvailable: true);

    expect(find.text(l.sourceFileTitle), findsOneWidget);
    expect(find.text(l.sourceForeignTitle), findsOneWidget);
    expect(find.text(l.sourcePhotosTitle), findsOneWidget);
  });

  testWidgets('the template can still be chosen without AI', (tester) async {
    SupplierExcelSource? chosen;
    await pump(
      tester,
      aiEnabled: false,
      photosAvailable: false,
      onChanged: (source) => chosen = source,
    );

    await tester.tap(find.text(l.sourceFileTitle));

    expect(chosen, SupplierExcelSource.file);
  });

  testWidgets('treats a missing flag as no AI', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              l = SupplierExcelImportI18n(context);
              return SupplierExcelSourceCard(source: null, onChanged: (_) {});
            },
          ),
        ),
      ),
    );

    expect(find.text(l.sourceForeignTitle), findsNothing);
    expect(find.text(l.sourcePhotosTitle), findsNothing);
  });
}
