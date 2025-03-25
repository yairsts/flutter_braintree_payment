class VenmoAccountNonce {
  VenmoAccountNonce({
    required this.nonce,
    required this.isDefault,
    this.username,
    this.email,
    this.externalId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  final String nonce;
  final bool isDefault;
  final String? username;
  final String? email;
  final String? externalId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;

  factory VenmoAccountNonce.fromJson(Map<String, dynamic> json) {
    return VenmoAccountNonce(
      nonce: json['nonce'],
      isDefault: json['isDefault'] ?? false,
      username: json['username'] as String?,
      email: json['email'] as String?,
      externalId: json['externalId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
      'isDefault': isDefault,
      'username': username,
      'email': email,
      'externalId': externalId,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    };
  }

  @override
  String toString() {
    return 'VenmoAccountNonce{nonce: $nonce, isDefault: $isDefault, username: $username, email: $email, externalId: $externalId, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber}';
  }
}
