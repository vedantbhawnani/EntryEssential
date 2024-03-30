import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rssb/ReportsPage.dart';
import 'package:rssb/admin.dart';

import 'OCR.dart';
import 'Report.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isValid = true;
  String text = '';
  TextEditingController plateNumber = TextEditingController();
  final passwordController = TextEditingController();
  String correctPassword = "godisone";

  List<Map<String, dynamic>> _searchResults = [];

  void _awaitOCR(BuildContext context) async {
    plateNumber.text = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => OCR()));
  }

  List<String> list = <String>['2-wheeler', '3-wheeler', '4-wheeler'];
  Map<String, dynamic> userInfo = {};
  late String selectedType = list.first;

  Future<List<Map<String, dynamic>>> searchVehicles(String number) async {
    // Create a reference to the vehicles collection (assuming 'vehicles' is the correct collection)
    final collection = FirebaseFirestore.instance
        .collection('cars'); // Modified collection name

    // Query the collection by number (assuming 'number' is the correct field name)
    final querySnapshot =
        await collection.where('fourNumber', isEqualTo: number).get();

    // Extract data and document IDs from matching documents
    final List<Map<String, dynamic>> vehiclesWithDocIds = [];
    for (final doc in querySnapshot.docs) {
      final vehicleData = doc.data();
      final docId = doc.reference.id;
      vehiclesWithDocIds.add({
        ...vehicleData, // Spread existing vehicle data
        'docId': docId, // Add document ID to the map
      });
    }
    return vehiclesWithDocIds;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Add appbar with drawer for reports and admin settings.
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Admin Access'),
              onTap: () async {
                await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('Enter Password'),
                          content: TextField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(labelText: 'Password'),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                final enteredPassword = passwordController.text;
                                if (enteredPassword == correctPassword) {
                                  passwordController.text = "";

                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Admin())); // Navigate
                                } else {
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text('Incorrect password'),
                                    ),
                                  );
                                }
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ));
              },
            ),
            ListTile(
              title: const Text('Report'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReportsPage()));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 30,
                        right: MediaQuery.of(context).size.width / 30),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2.5,
                        child: TextField(
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height / 28),
                          controller: plateNumber,
                          maxLength: 4,
                          keyboardType: TextInputType.none,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            errorText: isValid ? null : 'Enter 4 digit number.',
                            label: Text(''),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Wrap(spacing: 5.0, runSpacing: 10.0, children: [
                    ElevatedButton(
                      onPressed: () {
                        _awaitOCR(context);
                      },
                      child: const Text('OCR', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).size.width / 30,
                              MediaQuery.of(context).size.height / 10)),
                    ),
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width/50,
                    // ),
                    ElevatedButton(
                        onPressed: () {
                          if (plateNumber.text.length > 0) {
                            plateNumber.text = plateNumber.text
                                .substring(0, plateNumber.text.length - 1);
                          } else {
                            plateNumber.text = '';
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width / 4,
                                MediaQuery.of(context).size.height / 10)),
                        onLongPress: () {
                          plateNumber.text = "";
                        },
                        child:
                            const Text('DEL', style: TextStyle(fontSize: 18))),
                  ]),
                ],
              ),
              const SizedBox(height: 10),
              _searchResults.isEmpty
                  ? Text('No vehicles found')
                  : SingleChildScrollView(
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final vehicleData = _searchResults[index];
                            final plateNumber = vehicleData['VehicleNumber'];
                            final phoneNumber = vehicleData['MobileNumber'];
                            final ownerName = vehicleData['VehicleOwnerName'];
                            final address = vehicleData['Address'];
                            final make = vehicleData['Make'];
                            final color = vehicleData['Color'];
                            final driverName = vehicleData['DriverName'];
                            final driverPhone = vehicleData['DriverPhone'];
                            return ListTile(
                              title: Text(
                                  "Plate: $plateNumber\nOwner: $ownerName"),
                              subtitle: Wrap(
                                spacing: 5.0,
                                runSpacing: 10.0,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          24),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            vehicleData['MarkColor'] != null
                                                ? Colors.green
                                                : Colors.blueGrey),
                                    onPressed: () async {
                                      final docId = vehicleData[
                                          'docId']; // Access docId from the map
                                      // print(
                                      //     'TimeIn for $plateNumber, Doc ID: $docId');
                                      // Add your logic for handling TimeIn action (e.g., update data in Firebase with timestamp)
                                      FirebaseFirestore.instance
                                          .collection('cars')
                                          .doc(docId)
                                          .update({
                                        'TimeIn': DateTime.now(),
                                        'MarkColor': true,
                                      }).then((value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text('TimeIn Data Added'),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              ));
                                    },
                                    onLongPress: () async {
                                      final docId = vehicleData[
                                          'docId']; // Access docId from the map
                                      FirebaseFirestore.instance
                                          .collection('cars')
                                          .doc(docId)
                                          .update({
                                        'TimeIn': FieldValue.delete(),
                                        'MarkColor': FieldValue.delete()
                                      }).then((value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                      'TimeIn Data Deleted'),
                                                ),
                                              ));
                                    },
                                    child: Text('TimeIn'),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          7.5),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final docId = vehicleData[
                                          'docId']; // Access docId from the map
                                      print(
                                          'TimeOut for $plateNumber, Doc ID: $docId');
                                      // Add your logic for handling TimeOut action (e.g., update data in Firebase with timestamp)
                                      // You can use `FirebaseFirestore.instance.collection('vehicles').doc(docId).update(...)`
                                      FirebaseFirestore.instance
                                          .collection('cars')
                                          .doc(docId)
                                          .update({
                                        'TimeOut': DateTime.now()
                                      }).then((value) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                      'TimeOut Data Added'),
                                                ),
                                              ));
                                    },
                                    child: Text('TimeOut'),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          20),
                                  ElevatedButton(
                                    onPressed: () async {
                                      print(vehicleData);
                                      final docId = vehicleData[
                                          'docId']; // Access docId from the map
                                      // Add your logic for handling TimeIn action (e.g., update data in Firebase with timestamp)
                                      TextEditingController nameController =
                                          TextEditingController(
                                              text: ownerName);
                                      TextEditingController numberController =
                                          TextEditingController(
                                              text: phoneNumber);
                                      TextEditingController plateController =
                                          TextEditingController(
                                              text: plateNumber);
                                      TextEditingController addressController =
                                          TextEditingController(text: address);
                                      TextEditingController makeController =
                                          TextEditingController(text: make);
                                      TextEditingController colorController =
                                          TextEditingController(text: color);
                                      TextEditingController
                                          driverNameController =
                                          TextEditingController(
                                              text: driverName);
                                      TextEditingController
                                          driverPhoneController =
                                          TextEditingController(
                                              text: driverPhone);

                                      UpdateForm(
                                        context,
                                        nameController,
                                        numberController,
                                        plateController,
                                        addressController,
                                        makeController,
                                        colorController,
                                        driverNameController,
                                        driverPhoneController,
                                        docId,
                                      );
                                    },
                                    child: Text('Update Car Info'),
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          30),
                                  ElevatedButton(
                                    onPressed: () async {
                                      await CheckDelete(context, vehicleData);
                                    },
                                    child: Text('Delete Car Data'),
                                  ),
                                ],
                              ),
                            );
                          }),
                    ),
              const SizedBox(height: 10),
              Numpad(),
              const SizedBox(height: 10),
            ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await resetFirebaseValues().then(
                (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Values resetted.'),
                      behavior: SnackBarBehavior.floating,
                    )));
          },
          child: Icon(CupertinoIcons.refresh_thick)),
    );
  }

  Future<void> resetFirebaseValues() async {
    final firestore = FirebaseFirestore.instance;
    final today = DateTime.now();

    final querySnapshot = await firestore
        .collection('cars')
        .where('TimeIn',
            isGreaterThanOrEqualTo:
                DateTime(today.year, today.month, today.day))
        .where('TimeIn',
            isLessThanOrEqualTo:
                DateTime(today.year, today.month, today.day, 23, 59, 59))
        .get();

    final batch = firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {
        'TimeIn': FieldValue.delete(),
        'TimeOut': FieldValue.delete(), // Delete TimeOut
        'MarkColor': FieldValue.delete(), // Set MarkColor to empty string
      });
    }

    await batch.commit();
    print('Firebase values reset successfully!');
  }

  Column Numpad() {
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          numButton(
            number: '1',
          ),
          numButton(
            number: '2',
          ),
          numButton(
            number: '3',
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          numButton(
            number: '4',
          ),
          numButton(
            number: '5',
          ),
          numButton(
            number: '6',
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          numButton(
            number: '7',
          ),
          numButton(
            number: '8',
          ),
          numButton(
            number: '9',
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // SizedBox(
          //   width: 0,
          // ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                minimumSize: Size(120, 75),
                fixedSize: Size(MediaQuery.of(context).size.width / 8,
                    MediaQuery.of(context).size.height / 20)),
            child: Text('0', style: TextStyle(fontSize: 26)),
            onPressed: () {
              plateNumber.text += '0';
              plateNumber.value = TextEditingValue(
                  text: plateNumber.text,
                  selection: TextSelection.fromPosition(
                      TextPosition(offset: plateNumber.text.length)));
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                minimumSize: Size(120, 60),
                fixedSize: Size(MediaQuery.of(context).size.width / 8,
                    MediaQuery.of(context).size.height / 20)),
            onPressed: () async {
              final number = plateNumber.text;
              final results = await searchVehicles(number);
              setState(() {
                _searchResults = results;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(plateNumber.text),
                behavior: SnackBarBehavior.floating,
              ));
              plateNumber.text = "";
            },
            child: Text('Search', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    ]);
  }

  Future<dynamic> UpdateForm(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController numberController,
      TextEditingController plateController,
      TextEditingController addressController,
      TextEditingController makeController,
      TextEditingController colorController,
      TextEditingController driverNameController,
      TextEditingController driverPhoneController,
      String docId) {
    return showDialog(
        context: context,
        builder: (context) => SingleChildScrollView(
              child: AlertDialog(
                  title: Text('Update Car'),
                  content: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Name'),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: numberController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number'),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: plateController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Number'),
                      ),
                      SizedBox(height: 10),
                      TextField(
                          controller: addressController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Address',
                            //   errorText: 'Field cannot be empty!',
                          )),
                      SizedBox(height: 15),
                      TextField(
                          controller: makeController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Make',
                            //   errorText: 'Field cannot be empty!',
                          )),
                      SizedBox(height: 15),
                      TextField(
                          controller: colorController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Color',
                            //   errorText: 'Field cannot be empty!',
                          )),
                      SizedBox(height: 15),
                      Text('Driver Details'),
                      TextField(
                        controller: driverNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Driver Name',
                          // errorText: 'Field cannot be empty!',
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                          controller: driverPhoneController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Driver Phone Number',
                            //   errorText: 'Field cannot be empty!',
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
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded corners
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
                            color: Colors.black, fontSize: 16.0), // Text style
                        onChanged: (String? value) {
                          setState(() {
                            selectedType = value!;
                          });
                        },
                        items:
                            list.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                          onPressed: () async {
                            await CheckUpdate(
                              context,
                              nameController,
                              plateController,
                              numberController,
                              addressController,
                              makeController,
                              colorController,
                              driverNameController,
                              driverPhoneController,
                              docId,
                            );
                            Navigator.pop(context);
                          },
                          child: Text('Submit'))
                    ],
                  )),
            ));
  }

  Future<dynamic> CheckDelete(
      BuildContext context, Map<String, dynamic> vehicleData) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Enter Password'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final enteredPassword = passwordController.text;
                    if (enteredPassword == correctPassword) {
                      passwordController.text = "";

                      final docId =
                          vehicleData['docId']; // Access docId from the map
                      FirebaseFirestore.instance
                          .collection('cars')
                          .doc(docId)
                          .delete()
                          .then((value) => showDialog(
                              context: context, // Replace with your context
                              builder: (context) => AlertDialog(
                                    title: Text("Success"),
                                    content:
                                        Text("User data deleted successfully!"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("OK"),
                                      ),
                                    ],
                                  )))
                          .onError((error, stackTrace) => showDialog(
                                context: context, // Replace with your context
                                builder: (context) => AlertDialog(
                                  title: Text("Error"),
                                  content: Text(
                                      "Error deleting user data: ${error.toString()}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text("OK"),
                                    ),
                                  ],
                                ),
                              ));
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Incorrect password'),
                        ),
                      );
                    }
                  },
                  child: Text('OK'),
                ),
              ],
            ));
  }

  Future<dynamic> CheckUpdate(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController plateController,
      TextEditingController numberController,
      TextEditingController addressController,
      TextEditingController makeController,
      TextEditingController colorController,
      TextEditingController driverNameController,
      TextEditingController driverPhoneController,
      docId) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Enter Password'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final enteredPassword = passwordController.text;
                    if (enteredPassword == correctPassword) {
                      passwordController.text = "";
                      userInfo = {
                        'VehicleOwnerName': nameController.text,
                        'VehicleNumber': plateController.text,
                        'MobileNumber': numberController.text,
                        'VehicleType': selectedType,
                        'fourNumber': plateController.text
                            .substring(plateController.text.length - 4),
                        'Address': addressController.text,
                        'Make': makeController.text,
                        'Color': colorController.text,
                        'DriverName': driverNameController.text,
                        'DriverPhone': driverPhoneController.text,
                      };
                      FirebaseFirestore.instance
                          .collection('cars')
                          .doc(docId)
                          .update(userInfo)
                          .then((value) =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Updated Successfully'),
                                ),
                              ))
                          .then((value) => Navigator.pop(context));
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Incorrect password'),
                        ),
                      );
                    }
                  },
                  child: Text('OK'),
                ),
              ],
            ));
  }

  ElevatedButton numButton({required String number}) => ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: StadiumBorder(), minimumSize: Size(120, 75)),
        child: Text(number, style: TextStyle(fontSize: 26)),
        onPressed: () {
          plateNumber.text += number;
          plateNumber.value = TextEditingValue(
              text: plateNumber.text,
              selection: TextSelection.fromPosition(
                  TextPosition(offset: plateNumber.text.length)));
        },
      );
}
