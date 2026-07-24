import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/event_model.dart';

class EventService {

  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  Future<List<EventModel>> getEvents(String cityId) async {

    QuerySnapshot snapshot = await firestore
        .collection("events")
        .where("cityId", isEqualTo: cityId)
        .get();

    return snapshot.docs.map((doc) {

      return EventModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );

    }).toList();
  }
}