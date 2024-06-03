// ignore: file_names
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rssb/Helper/Helper.dart';
import 'ReportsPage.dart';
import 'admin.dart';

class HomePage extends StatefulWidget {
  final String name;
  const HomePage({super.key, required this.name});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isValid = true;
  String text = '';
  TextEditingController plateNumber = TextEditingController();
  final passwordController = TextEditingController();
  String correctPassword = "godisone";
  bool _showSearchResults = false;

  List<Map<String, dynamic>> _searchResults = [];

  List<String> list = <String>['2-wheeler', '3-wheeler', '4-wheeler'];
  Map<String, dynamic> userInfo = {};
  late String selectedType = list.first;

  String selectedGate = "Gate 1";
  final List<String> gateNumbers = ["Gate 1", "Gate 2", "Gate 3"];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            const Spacer(), // Add Spacer before actions
            PopupMenuButton<String>(
              icon: Row(
                children: [
                  Text(
                    selectedGate,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 40,
                  ), // Add dropdown icon
                ],
              ),
              onSelected: (value) => setState(() => selectedGate = value),
              itemBuilder: (context) => gateNumbers
                  .map((gate) => PopupMenuItem<String>(
                        value: gate,
                        child: Text(gate),
                      ))
                  .toList(),
            ),
            const Spacer(flex: 4),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Admin Access'),
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Enter Password'),
                            content: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration:
                                  const InputDecoration(labelText: 'Password'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  final enteredPassword =
                                      passwordController.text;
                                  if (enteredPassword == correctPassword) {
                                    passwordController.text = "";

                                    Navigator.pop(context);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Admin())); // Navigate
                                  } else {
                                    // Show error message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        behavior: SnackBarBehavior.floating,
                                        content: Text('Incorrect password'),
                                      ),
                                    );
                                  }
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ));
                },
              ),
              ListTile(
                title: const Text('Report'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ReportsPage()));
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
                            keyboardType: TextInputType.none,
                            maxLength: 4,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              errorText:
                                  isValid ? null : 'Enter 4 digit number.',
                              label: const Text(''),
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
                        onPressed: () => setState(() {
                          _showSearchResults = false;
                        }),
                        style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width / 30,
                                MediaQuery.of(context).size.height / 10)),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (plateNumber.text.isNotEmpty) {
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
                          child: const Text('DEL',
                              style: TextStyle(fontSize: 18))),
                    ]),
                  ],
                ),
                const SizedBox(height: 10),
                Visibility(
                    visible: !_showSearchResults,
                    child: Container(
                      height: MediaQuery.of(context).size.height / 3.5,
                    )),
                Visibility(
                  visible: _showSearchResults,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 3.5,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio:
                                MediaQuery.of(context).size.height / 400),
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final vehicleData = _searchResults[index];
                          final plateNumber = vehicleData['VehicleNumber'];
                          final ownerName = vehicleData['VehicleOwnerName'];
                          final make = vehicleData['Make'] ?? "";
                          final phoneNumber = vehicleData['MobileNumber'] ?? "";
                          return Card(

                            child: Column(
                              children: [
                                Wrap(
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              vehicleData['MarkColor'] != null
                                                  ? Colors.green
                                                  : const Color.fromARGB(
                                                      255, 206, 219, 223)),
                                      onPressed: () async {
                                        final docId = vehicleData['docId'];
                                        final carDoc = await FirebaseFirestore
                                            .instance
                                            .collection('cars')
                                            .doc(docId)
                                            .get();
                                        if (carDoc.data()?['TimeIn'] == null) {
                                          FirebaseFirestore.instance
                                              .collection('cars')
                                              .doc(docId)
                                              .update({
                                                'TimeIn': DateTime.now(),
                                                'MarkColor': true,
                                                'Gate': selectedGate,
                                                'User': widget.name
                                              })
                                              .then(
                                                (value) {
                                                  print(selectedGate);
                                                  FirebaseFirestore.instance
                                                      .collection('gateCounts')
                                                      .doc(selectedGate)
                                                      .update({
                                                    "count":
                                                        FieldValue.increment(1)
                                                  });
                                                },
                                              )
                                              .then((value) => setState(() {
                                                    _showSearchResults = false;
                                                  }))
                                              .then((value) =>
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'TimeIn Data Added'),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content:
                                                Text('Car already entered.'),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                          _showSearchResults = false;
                                        }
                                      },
                                      onLongPress: () async {
                                        final docId = vehicleData['docId'];
                                        FirebaseFirestore.instance
                                            .collection('cars')
                                            .doc(docId)
                                            .update({
                                              'TimeIn': FieldValue.delete(),
                                              'MarkColor': FieldValue.delete(),
                                              'User': FieldValue.delete(),
                                            })
                                            .then(
                                              (value) => setState(() {
                                                _showSearchResults = false;
                                              }),
                                            )
                                            .then(
                                              (value) => FirebaseFirestore
                                                  .instance
                                                  .collection('gateCounts')
                                                  .doc(selectedGate)
                                                  .update({
                                                "count":
                                                    FieldValue.increment(-1)
                                              }),
                                            )
                                            .then((value) =>
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    content: Text(
                                                        'TimeIn Data Deleted'),
                                                  ),
                                                ));
                                      },
                                      child: Text('$plateNumber'),
                                    ),
                                  ],
                                ),
                                if (make.isNotEmpty)
                                Text(
                                  "$ownerName\n$phoneNumber\n$make",
                                  style: const TextStyle(color: Colors.black),
                                ),
                                if (!make.isNotEmpty)
                                Text(
                                  "$ownerName\n$phoneNumber",
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height / 50),
                Numpad(),
                SizedBox(height: MediaQuery.of(context).size.height / 50),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('gateCounts')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final gateCountsData = snapshot.data!.docs;
                        Map<String, int> gateCounts = {};
                        for (var doc in gateCountsData) {
                          gateCounts[doc.id] = doc['count'];
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Gate 1: ${gateCounts['Gate 1'].toString()}'),
                            Text('Gate 2: ${gateCounts['Gate 2'].toString()}'),
                            Text('Gate 3: ${gateCounts['Gate 3'].toString()}'),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),
        
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final firestore = FirebaseFirestore.instance;
              final collection = firestore.collection('cars');

              try {
                const filePath = 'assets/combined_new.json';
                final String jsonString = await rootBundle.loadString(filePath);
                final List<dynamic> jsonData = jsonDecode(jsonString);

                final modifiedData = jsonData
                    .map((map) {
                      final vehicleNumber = map['VehicleNumber']?.toString();
                      if (vehicleNumber != null && vehicleNumber.length >= 4) {
                        final fourNumber =
                            vehicleNumber.substring(vehicleNumber.length - 4);
                        map['fourNumber'] = fourNumber;
                      }
                      return map;
                    })
                    .toList()
                    .cast<Map<String, dynamic>>();

                for (final map in modifiedData) {
                  await collection.add(map);
                }

                print('Data uploaded successfully!');
              } catch (error) {
                print('Error uploading data: $error');
              }
            },
            child: const Icon(Icons.add)));
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
                minimumSize: Size(MediaQuery.of(context).size.width / 3.5,
                    MediaQuery.of(context).size.height / 13),
                fixedSize: Size(MediaQuery.of(context).size.width / 8,
                    MediaQuery.of(context).size.height / 20)),
            child: const Text('0', style: TextStyle(fontSize: 26)),
            onPressed: () {
              plateNumber.text += '0';
              plateNumber.value = TextEditingValue(
                  text: plateNumber.text,
                  selection: TextSelection.fromPosition(
                      TextPosition(offset: plateNumber.text.length)));
            },
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                minimumSize: Size(MediaQuery.of(context).size.width / 2,
                    MediaQuery.of(context).size.height / 13),
                fixedSize: Size(MediaQuery.of(context).size.width / 8,
                    MediaQuery.of(context).size.height / 20),
                backgroundColor: const Color.fromARGB(255, 46, 123, 213)),
            onPressed: () async {
              final number = plateNumber.text;
              final results =
                  await DatabaseHelper.instance.searchVehicles(number);
              setState(() {
                _searchResults = results;
                _showSearchResults = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(plateNumber.text),
                behavior: SnackBarBehavior.floating,
              ));
              plateNumber.text = "";
            },
            child: const Text('Search',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
          ),
          const Spacer(),
        ],
      ),
    ]);
  }

  ElevatedButton numButton({required String number}) => ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(),
            minimumSize: Size(MediaQuery.of(context).size.width / 3.5,
                MediaQuery.of(context).size.height / 13)),
        child: Text(number, style: const TextStyle(fontSize: 26)),
        onPressed: () {
          if (plateNumber.text.length < 4) {
            plateNumber.text += number;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Maximum length reached'),
              duration: Duration(milliseconds: 500),
            ));
          }
          plateNumber.value = TextEditingValue(
              text: plateNumber.text,
              selection: TextSelection.fromPosition(
                  TextPosition(offset: plateNumber.text.length)));
        },
      );

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
                  title: const Text('Update Car'),
                  content: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Name'),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: numberController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone Number'),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: plateController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Number'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                          controller: addressController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Address',
                            //   errorText: 'Field cannot be empty!',
                          )),
                      const SizedBox(height: 15),
                      TextField(
                          controller: makeController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Make',
                          )),
                      const SizedBox(height: 15),
                      TextField(
                          controller: colorController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Color',
                          )),
                      const SizedBox(height: 15),
                      const Text('Driver Details'),
                      TextField(
                        controller: driverNameController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Driver Name',
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                          controller: driverPhoneController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Driver Phone Number',
                          )),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
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
                          child: const Text('Submit'))
                    ],
                  )),
            ));
  }

  Future<dynamic> CheckDelete(
      BuildContext context, Map<String, dynamic> vehicleData) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Enter Password'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
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
                                    title: const Text("Success"),
                                    content: const Text(
                                        "User data deleted successfully!"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  )))
                          .onError((error, stackTrace) => showDialog(
                                context: context, // Replace with your context
                                builder: (context) => AlertDialog(
                                  title: const Text("Error"),
                                  content: Text(
                                      "Error deleting user data: ${error.toString()}"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ),
                              ));
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Incorrect password'),
                        ),
                      );
                    }
                  },
                  child: const Text('OK'),
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
              title: const Text('Enter Password'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
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
                          .then((value) => setState(() {
                                _showSearchResults = false;
                              }))
                          .then((value) =>
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('Updated Successfully'),
                                ),
                              ))
                          .then((value) => Navigator.pop(context));
                    } else {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Incorrect password'),
                        ),
                      );
                    }
                  },
                  child: const Text('OK'),
                ),
              ],
            ));
  }
}
