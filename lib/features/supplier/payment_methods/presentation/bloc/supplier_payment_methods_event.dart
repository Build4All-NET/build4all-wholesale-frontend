abstract class SupplierPaymentMethodsEvent {
  const SupplierPaymentMethodsEvent();
}

class SupplierPaymentMethodsStarted extends SupplierPaymentMethodsEvent {
  const SupplierPaymentMethodsStarted();
}

class SupplierPaymentMethodsRefreshed extends SupplierPaymentMethodsEvent {
  const SupplierPaymentMethodsRefreshed();
}

/// Toggle enable / disable for CASH (and future simple methods).
class SupplierPaymentMethodToggled extends SupplierPaymentMethodsEvent {
  final String methodCode;
  final bool enabled;

  const SupplierPaymentMethodToggled({
    required this.methodCode,
    required this.enabled,
  });
}

/// Save credentials for a method that requires them (e.g. STRIPE).
class SupplierPaymentMethodConfigSaved extends SupplierPaymentMethodsEvent {
  final String methodCode;
  final bool enabled;
  final Map<String, dynamic> configValues;

  const SupplierPaymentMethodConfigSaved({
    required this.methodCode,
    required this.enabled,
    required this.configValues,
  });
}

/// Test the connection/credentials for a method.
class SupplierPaymentMethodTested extends SupplierPaymentMethodsEvent {
  final String methodCode;

  const SupplierPaymentMethodTested({required this.methodCode});
}
