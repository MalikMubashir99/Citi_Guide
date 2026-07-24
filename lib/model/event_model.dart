class EventModel {
  String id;
  String title;
  String cityId;
  String image;
  String description;
  String date;
  String time;
  String location;

  EventModel({
    required this.id,
    required this.title,
    required this.cityId,
    required this.image,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
  });

  factory EventModel.fromFirestore(
      Map<String, dynamic> data,
      String id,
      ) {

    return EventModel(
      id: id,
      title: data['title'] ?? '',
      cityId: data['cityId'] ?? '',
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      location: data['location'] ?? '',
    );
  }
}