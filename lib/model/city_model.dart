class CityModel {

  String id;
  String name;
  String? image;
  String description;

  CityModel({
    required this.id,
    required this.name,
     this.image,
    required this.description,
  });


  factory CityModel.fromFirestore(
      Map<String,dynamic> data,
      String id
      ){

    return CityModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
    );

  }


  Map<String,dynamic> toMap(){

    return {

      "name": name,
      "image": image,
      "description": description,

    };

  }

}