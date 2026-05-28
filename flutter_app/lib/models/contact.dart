class ContactModel {
  const ContactModel({
    required this.id,
    required this.name,
    required this.address,
  });

  final int id;
  final String name;
  final String address;

  ContactModel copyWith({int? id, String? name, String? address}) {
    return ContactModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
    };
  }

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
    );
  }
}
