class UserModel {
  String uid;
  String name;
  String email;
  String phone;
  String image;
  String role;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.role
  });

  factory UserModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return UserModel(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      image: data['image'] ?? '',
      role: data['role'] ?? 'user',

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'role':role,
    };
  }
}