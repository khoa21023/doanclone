class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.avatarUrl,
  });
}