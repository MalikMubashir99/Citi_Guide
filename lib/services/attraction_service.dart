import 'package:app/model/attraction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AttractionService {


final FirebaseFirestore firestore =
FirebaseFirestore.instance;



Future<List<AttractionModel>> getAttractions(
String cityId
) async {



QuerySnapshot snapshot = await firestore
.collection('attractions')
.where(
'cityId',
isEqualTo: cityId
)
.get();



return snapshot.docs.map((doc){


return AttractionModel.fromFirestore(

doc.data() as Map<String,dynamic>,

doc.id

);


}).toList();



}


}