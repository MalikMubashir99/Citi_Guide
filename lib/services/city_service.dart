import 'package:app/model/city_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CityService {


final FirebaseFirestore firestore =
FirebaseFirestore.instance;



Future<List<CityModel>> getCities() async {


final snapshot =
await firestore.collection('cities').get();


return snapshot.docs.map((doc){


return CityModel.fromFirestore(
doc.data(),
doc.id
);


}).toList();



}



}