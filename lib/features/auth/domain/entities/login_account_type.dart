enum LoginAccountType {
  supplier,
  retailer,
}

extension LoginAccountTypeX on LoginAccountType {
  bool get isSupplier => this == LoginAccountType.supplier;
  bool get isRetailer => this == LoginAccountType.retailer;

  String get title {
    switch (this) {
      case LoginAccountType.supplier:
        return 'Owner';
      case LoginAccountType.retailer:
        return 'User';
    }
  }
}