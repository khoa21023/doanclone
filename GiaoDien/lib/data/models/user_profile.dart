class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: (json['Id'] ?? json['id'] ?? '').toString(),
      name: json['HoTen'] ?? json['name'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      phone: json['SoDienThoai'] ?? json['phone'] ?? '',
      address: json['DiaChi'] ?? json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'HoTen': name,
      'Email': email,
      'SoDienThoai': phone,
      'DiaChi': address,
    };
  }
}
