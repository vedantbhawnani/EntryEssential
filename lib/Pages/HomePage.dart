// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rssb/Helper/Helper.dart';
import 'ReportsPage.dart';
import 'admin.dart';

class HomePage extends StatefulWidget {
  final String name;
  HomePage({super.key, required this.name});

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
          Spacer(), // Add Spacer before actions
          PopupMenuButton<String>(
            icon: Row(
              children: [
                Text(
                  "$selectedGate",
                  style: TextStyle(
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
          Spacer(flex: 4), // Add Spacer after actions
        ],
      ),
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
                      onPressed: () => setState(() {
                        _showSearchResults = false;
                      }),
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: Size(
                              MediaQuery.of(context).size.width / 30,
                              MediaQuery.of(context).size.height / 10)),
                    ),
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
              Visibility(
                visible: _showSearchResults,
                child: SingleChildScrollView(
                  child: Container(
                    height: 250,
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
                        // final address = vehicleData['Address'];
                        // final color = vehicleData['Color'];
                        // final driverName = vehicleData['DriverName'];
                        // final driverPhone = vehicleData['DriverPhone'];
                        return GridTile(
                          footer: GridTileBar(
                              title: Flexible(
                            child: Text(
                              "$make\n$ownerName\n$phoneNumber",
                              style: TextStyle(color: Colors.black),
                            ),
                          )),
                          child: Wrap(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: vehicleData['MarkColor'] !=
                                            null
                                        ? Colors.green
                                        : Color.fromARGB(255, 206, 219, 223)),
                                onPressed: () async {
                                  final docId = vehicleData['docId'];
                                  FirebaseFirestore.instance
                                      .collection('cars')
                                      .doc(docId)
                                      .update({
                                        'TimeIn': DateTime.now(),
                                        'MarkColor': true,
                                        'Gate': selectedGate,
                                        'User': widget.name
                                      })
                                      .then((value) => setState(() {
                                            _showSearchResults = false;
                                          }))
                                      .then((value) =>
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
                                        'MarkColor': FieldValue.delete(),
                                        'User': FieldValue.delete(),
                                      })
                                      .then((value) => setState(() {
                                            _showSearchResults = false;
                                          }))
                                      .then((value) =>
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content:
                                                  Text('TimeIn Data Deleted'),
                                            ),
                                          ));
                                },
                                child: Text('$plateNumber'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Numpad(),
              SizedBox(height: 10),
            ]),
          ),
        ),
      ),
    );
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
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(),
                minimumSize: Size(MediaQuery.of(context).size.width / 3.5,
                    MediaQuery.of(context).size.height / 13),
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
          Spacer(),
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
            child: Text('Search',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87)),
          ),
          Spacer(),
        ],
      ),
    ]);
  }

  ElevatedButton numButton({required String number}) => ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(),
            minimumSize: Size(MediaQuery.of(context).size.width / 3.5,
                MediaQuery.of(context).size.height / 13)),
        child: Text(number, style: TextStyle(fontSize: 26)),
        onPressed: () {
          if (plateNumber.text.length < 4) {
            plateNumber.text += number;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
                          )),
                      SizedBox(height: 15),
                      TextField(
                          controller: colorController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Vehicle Color',
                          )),
                      SizedBox(height: 15),
                      Text('Driver Details'),
                      TextField(
                        controller: driverNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Driver Name',
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                          controller: driverPhoneController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Driver Phone Number',
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
                          .then((value) => setState(() {
                                _showSearchResults = false;
                              }))
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
}
