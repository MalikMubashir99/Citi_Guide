class ReviewModel {
  String id;
  String userId;
  String attractionId;
  String userName;
  double rating;
  String comment;
  DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.attractionId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(
      Map<String, dynamic> data,
      String id) {
    return ReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      attractionId: data['attractionId'] ?? '',
      userName: data['userName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      createdAt:
          (data['createdAt']).toDate(),
    );
  }
}