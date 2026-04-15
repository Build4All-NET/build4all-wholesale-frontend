class Build4AllSupplierSyncRequestModel {
  final String fullName;
  final String email;
  final String password;

  const Build4AllSupplierSyncRequestModel({
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }
}
