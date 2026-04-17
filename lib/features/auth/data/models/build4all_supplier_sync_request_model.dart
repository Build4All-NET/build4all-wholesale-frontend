class Build4AllSupplierSyncRequestModel {
  final int? build4allUserId;
  final int? ownerProjectLinkId;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String email;
  final String password;

  const Build4AllSupplierSyncRequestModel({
    required this.build4allUserId,
    required this.ownerProjectLinkId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'build4allUserId': build4allUserId,
      'ownerProjectLinkId': ownerProjectLinkId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'email': email,
      'password': password,
    };
  }
}