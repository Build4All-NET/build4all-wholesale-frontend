import 'package:build4all_wholesale_frontend/features/supplier/excel_import/presentation/bloc/supplier_excel_import_state.dart';
import 'package:flutter_test/flutter_test.dart';

/// With no AI the template is the only way to import, so it is already chosen
/// when the screen opens. With AI the supplier is still asked.
void main() {
  final initial = SupplierExcelImportState.initial();

  test('the template is chosen for a store without AI', () {
    expect(initial.effectiveSource(aiEnabled: false), SupplierExcelSource.file);
  });

  test('nothing is chosen for a store with AI, so the supplier is asked', () {
    expect(initial.effectiveSource(aiEnabled: true), isNull);
  });

  test('a source the supplier picked is kept', () {
    final picked = initial.copyWith(source: SupplierExcelSource.photos);

    expect(picked.effectiveSource(aiEnabled: true), SupplierExcelSource.photos);
    expect(picked.effectiveSource(aiEnabled: false), SupplierExcelSource.photos);
  });
}
