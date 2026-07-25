import 'package:flutter/material.dart';

import '../../services/city_service.dart';

class AddCityScreen extends StatefulWidget {
  const AddCityScreen({super.key});

  @override
  State<AddCityScreen> createState() =>
      _AddCityScreenState();
}


class _AddCityScreenState extends State<AddCityScreen> {

  final CityService cityService = CityService();


  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController imageController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();


  bool loading = false;



  Future<void> saveCity() async {


    if(nameController.text.trim().isEmpty ||
       imageController.text.trim().isEmpty ||
       descriptionController.text.trim().isEmpty){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fill all fields"),
        ),
      );

      return;
    }



    setState(() {
      loading = true;
    });



    await cityService.addCity(

      name: nameController.text.trim(),

      image: imageController.text.trim(),

      description:
          descriptionController.text.trim(),

    );



    setState(() {
      loading = false;
    });



    if(!mounted) return;



    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text("City Added"),
      ),

    );



    Navigator.pop(context);

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Add City"),
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(

          children: [


            TextField(

              controller: nameController,

              decoration: const InputDecoration(
                labelText: "City Name",
              ),

            ),


            const SizedBox(height:20),



            TextField(

              controller: imageController,

              decoration: const InputDecoration(
                labelText: "Image URL",
              ),

            ),



            const SizedBox(height:20),



            TextField(

              controller: descriptionController,

              maxLines:4,

              decoration: const InputDecoration(
                labelText: "Description",
              ),

            ),



            const SizedBox(height:30),



            SizedBox(

              width:double.infinity,


              child: ElevatedButton(

                onPressed:
                    loading ? null : saveCity,


                child: loading

                    ? const CircularProgressIndicator()

                    : const Text(
                        "Save City",
                      ),

              ),

            )


          ],

        ),

      ),

    );

  }

}