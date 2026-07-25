class AttractionModel {
  String id;
  String name;
  String cityId;
  String description;
  String image;
  double rating;
  String openingHours;
  String phone;
  String website;
  double latitude;
  double longitude;

  AttractionModel({
    required this.id,
    required this.name,
    required this.cityId,
    required this.description,
    required this.image,
    required this.rating,
    required this.openingHours,
    required this.phone,
    required this.website,
    required this.latitude,
    required this.longitude,
  });

  factory AttractionModel.fromFirestore(
      Map<String, dynamic> data,
      String id,
      ) {
    return AttractionModel(
      id: id,
      name: data['name'] ?? '',
      cityId: data['cityId'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      openingHours: data['openingHours'] ?? '',
      phone: data['phone'] ?? '',
      website: data['website'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cityId': cityId,
      'description': description,
      'image': image,
      'rating': rating,
      'openingHours': openingHours,
      'phone': phone,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}