import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController plateController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController makeController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController driverNameController = TextEditingController();
  TextEditingController driverPhoneController = TextEditingController();
  List<String> list = <String>['2-wheeler', '3-wheeler', '4-wheeler'];
  Map<String, dynamic> userInfo = {};

  @override
  Widget build(BuildContext context) {
    String selectedType = list.first;
    return Scaffold(
        appBar: AppBar(),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Center(child: Text('Admin Access', style: TextStyle(fontSize: 25))),
            ElevatedButton(
                onPressed: () {
                  // TODO: Check if any fields empty, prompt user to fill fields.
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                          title: Text('Add new Car'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      errorText: nameController.text.length == 0
                                          ? 'Field cannot be empty!'
                                          : null,
                                      labelText: 'Name'),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                  controller: numberController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Phone Number',
                                    errorText: 'Field cannot be empty!',
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                    controller: plateController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Vehicle Number',
                                      errorText: 'Field cannot be empty!',
                                    )),
                                SizedBox(height: 15),
                                TextField(
                                    controller: addressController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Address',
                                      errorText: 'Field cannot be empty!',
                                    )),
                                SizedBox(height: 15),
                                TextField(
                                    controller: makeController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Vehicle Make',
                                      errorText: 'Field cannot be empty!',
                                    )),
                                SizedBox(height: 15),
                                TextField(
                                    controller: colorController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Vehicle Color',
                                      errorText: 'Field cannot be empty!',
                                    )),
                                SizedBox(height: 15),
                                Text('Driver Details'),
                                TextField(
                                  controller: driverNameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Driver Name',
                                    errorText: 'Field cannot be empty!',
                                  ),
                                ),
                                SizedBox(height: 15),
                                TextField(
                                    controller: driverPhoneController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Driver Phone Number',
                                      errorText: 'Field cannot be empty!',
                                    )),
                                SizedBox(height: 10),
                                DropdownButtonFormField<String>(
                                  // Using DropdownButtonFormField for decoration
                                  value: selectedType,
                                  icon: const Icon(Icons.arrow_downward,
                                      color: Colors.deepPurple),
                                  elevation: 16,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Rounded corners
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurpleAccent,
                                          width: 1.0), // Colored border
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      // Enhanced border on focus
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: const BorderSide(
                                          color: Colors.deepPurple, width: 2.0),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15.0,
                                        vertical: 10.0), // Adjust padding
                                    hintStyle: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16.0), // Hint text style
                                  ),
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0), // Text style
                                  onChanged: (String? value) {
                                    setState(() {
                                      selectedType = value!;
                                    });
                                  },
                                  items: list.map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                    onPressed: () {
                                      if (nameController.text != "" &&
                                          plateController.text != "" &&
                                          numberController.text != "") {
                                        userInfo = {
                                          'VehicleOwnerName':
                                              nameController.text,
                                          'VehicleNumber': plateController.text,
                                          'MobileNumber': numberController.text,
                                          'VehicleType': selectedType,
                                          'four-number': plateController.text
                                              .substring(
                                                  plateController.text.length -
                                                      4),
                                          'address': addressController.text,
                                          'make': makeController.text,
                                          'color': colorController.text,
                                          'driverName':
                                              driverNameController.text,
                                          'driverPhone':
                                              driverPhoneController.text,
                                        };
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .add(userInfo);
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text('Submit'))
                              ],
                            ),
                          )));
                },
                child: Text('Add Car')),
          ],
        ));
  }
}
