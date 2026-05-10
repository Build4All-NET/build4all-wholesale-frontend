import 'package:equatable/equatable.dart';

abstract class SupplierDashboardEvent extends Equatable {
  const SupplierDashboardEvent();

  @override
  List<Object?> get props => [];
}

class SupplierDashboardStarted extends SupplierDashboardEvent {
  const SupplierDashboardStarted();
}

class SupplierDashboardRefreshed extends SupplierDashboardEvent {
  const SupplierDashboardRefreshed();
}