class EmergencyContact {
  final String name;
  final String number;

  EmergencyContact({required this.name, required this.number});

  Map<String, dynamic> toJson() => {
        'name': name,
        'number': number,
      };

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      number: json['number'],
    );
  }
}
