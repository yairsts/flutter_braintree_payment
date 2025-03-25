class PayPalAccountNonce {
  PayPalAccountNonce({
    required this.nonce,
    required this.isDefault,
    this.clientMetadataId,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.payerId,
    this.authenticateUrl,
  });

  final String nonce;
  final bool isDefault;
  final String? clientMetadataId;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? payerId;
  final String? authenticateUrl;

  factory PayPalAccountNonce.fromJson(Map<String, dynamic> json) {
    return PayPalAccountNonce(
      nonce: json['nonce'] as String,
      isDefault: json['isDefault'] as bool,
      clientMetadataId: json['clientMetadataId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      payerId: json['payerId'] as String,
      authenticateUrl: json['authenticateUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nonce': nonce,
      'isDefault': isDefault,
      'clientMetadataId': clientMetadataId,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'email': email,
      'payerId': payerId,
      'authenticateUrl': authenticateUrl,
    };
  }

  @override
  String toString() {
    return 'PayPalAccountNonce{nonce: $nonce, isDefault: $isDefault, clientMetadataId: $clientMetadataId, firstName: $firstName, lastName: $lastName, phone: $phone, email: $email, payerId: $payerId, authenticateUrl: $authenticateUrl}';
  }
}
