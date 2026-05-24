abstract class SupplierPaymentMethodsEvent {
  const SupplierPaymentMethodsEvent();
}

class SupplierPaymentMethodsStarted extends SupplierPaymentMethodsEvent {
  const SupplierPaymentMethodsStarted();
}

class SupplierPaymentMethodsRefreshed extends SupplierPaymentMethodsEvent {
  const SupplierPaymentMethodsRefreshed();
}

class SupplierPaymentMethodToggled extends SupplierPaymentMethodsEvent {
  final String methodCode;
  final bool enabled;

  const SupplierPaymentMethodToggled({
    required this.methodCode,
    required this.enabled,
  });
}
