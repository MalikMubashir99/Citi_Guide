class FavoriteModel {
  final String id;
  final String userId;
  final String attractionId;

  FavoriteModel({
    required this.id,
    required this.userId,
    required this.attractionId,
  });

  factory FavoriteModel.fromFirestore(
      Map<String, dynamic> data,
      String id) {
    return FavoriteModel(
      id: id,
      userId: data['userId'],
      attractionId: data['attractionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'attractionId': attractionId,
    };
  }
}