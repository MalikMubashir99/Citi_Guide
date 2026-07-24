class RestaurantModel {

  String id;
  String name;
  String cityId;
  String image;
  String description;
  double rating;
  String phone;
  double latitude;
  double longitude;


  RestaurantModel({

    required this.id,
    required this.name,
    required this.cityId,
    required this.image,
    required this.description,
    required this.rating,
    required this.phone,
    required this.latitude,
    required this.longitude,

  });



  factory RestaurantModel.fromFirestore(
      Map<String,dynamic> data,
      String id
      ){

    return RestaurantModel(

      id: id,

      name: data['name'] ?? '',

      cityId: data['cityId'] ?? '',

      image: data['image'] ?? '',

      description:
      data['description'] ?? '',


      rating:
      (data['rating'] ?? 0).toDouble(),


      phone:
      data['phone'] ?? '',


      latitude:
      (data['latitude'] ?? 0).toDouble(),


      longitude:
      (data['longitude'] ?? 0).toDouble(),

    );

  }


}