abstract class SupplierProfileDisplayEvent {
  const SupplierProfileDisplayEvent();
}

class LoadSupplierProfileDisplayRequested
    extends SupplierProfileDisplayEvent {
  const LoadSupplierProfileDisplayRequested();
}

class RefreshSupplierProfileDisplayRequested
    extends SupplierProfileDisplayEvent {
  const RefreshSupplierProfileDisplayRequested();
}
