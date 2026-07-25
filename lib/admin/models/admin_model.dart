class AdminModel {
  final String id;
  final String name;
  final String email;
  final String role;

  AdminModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AdminModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return AdminModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }
}