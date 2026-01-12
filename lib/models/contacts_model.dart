class WhatsappContact {
  final String id;
  final String sponsorName;
  final String phone; // ✅ الأساسي فقط

  const WhatsappContact({
    required this.id,
    required this.sponsorName,
    required this.phone,
  });

  factory WhatsappContact.fromJson(Map<String, dynamic> json) {
    return WhatsappContact(
      id: (json['id'] ?? json['sponsorId'] ?? '').toString(),
      sponsorName: (json['sponsorName'] ?? json['name'] ?? '').toString(),
      phone: (json['phone'] ?? json['mainPhone'] ?? json['phoneNumber'] ?? '').toString(),
    );
  }
}
