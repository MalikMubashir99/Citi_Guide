// lib/model/user_model.dart
class UserModel {
  String uid;
  String name;
  String email;
  String phone;
  String image;
  String role;
  List<String> readNotifications;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.image,
    required this.role,
    this.readNotifications = const [],

  });

    bool isNotificationRead(String notificationId) {
    return readNotifications.contains(notificationId);
  }

  factory UserModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return UserModel(
      uid: id,  // ✅ Document ID as uid
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      image: data['image'] ?? '',
      role: data['role'] ?? 'user',
      readNotifications: List<String>.from(data['readNotifications'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'role': role,
      'readNotifications': readNotifications,
    };
  }
   UserModel addReadNotification(String notificationId) {
    if (readNotifications.contains(notificationId)) return this;
    return UserModel(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      image: image,
      role: role,
      readNotifications: [...readNotifications, notificationId],
    );
  }
}