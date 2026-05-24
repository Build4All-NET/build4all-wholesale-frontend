import 'package:equatable/equatable.dart';

abstract class SupplierDashboardEvent extends Equatable {
  SupplierDashboardEvent();

  @override
  List<Object?> get props => [];
}

class SupplierDashboardStarted extends SupplierDashboardEvent {
  SupplierDashboardStarted();
}

class SupplierDashboardRefreshed extends SupplierDashboardEvent {
  SupplierDashboardRefreshed();
}