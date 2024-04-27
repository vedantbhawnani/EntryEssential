import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateCarPage extends StatefulWidget {
  @override
  _UpdateCarPageState createState() => _UpdateCarPageState();
}

class _UpdateCarPageState extends State<UpdateCarPage> {
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers for user input
  final carNumberController = TextEditingController();
  final nameController = TextEditingController();
  final plateController = TextEditingController();
  final numberController = TextEditingController();
  var selectedType = '';
  final addressController = TextEditingController(text: "");
  final makeController = TextEditingController(text: "");
  final colorController = TextEditingController(text: "");
  final driverNameController = TextEditingController(text: "");
  final driverPhoneController = TextEditingController(text: "");
  final fourNumberController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference? carRef; // Document reference for the car (initially null)
  List<String> list = <String>['2-wheeler', '3-wheeler', '4-wheeler'];

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  void dispose() {
    carNumberController.dispose();
    nameController.dispose();
    plateController.dispose();
    numberController.dispose();
    addressController.dispose();
    makeController.dispose();
    colorController.dispose();
    driverNameController.dispose();
    driverPhoneController.dispose();
    fourNumberController.dispose();
    super.dispose();
  }

  Future<void> _findCarByNumber() async {
    final carNumber = carNumberController.text;
    if (carNumber.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Not found')));
      return;
    }

    try {
      QuerySnapshot snapshot = await firestore
          .collection('cars')
          .where('VehicleNumber', isEqualTo: carNumber)
          .get();
      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car not found with that number!')),
        );
        return;
      }

      DocumentSnapshot carData = snapshot.docs[0];
      print(carData.data().toString());
      carRef = carData.reference;
      nameController.text = carData['VehicleOwnerName'];
      plateController.text = carData['VehicleNumber'];
      numberController.text = carData['MobileNumber'];
      selectedType = carData['VehicleType'] ?? "";
      addressController.text = carData['Address'];
      makeController.text = carData['Make'] ?? '';
      colorController.text = carData['Color'] ?? '';
      driverNameController.text = carData['DriverName'] ?? '';
      driverPhoneController.text = carData['DriverPhone'] ?? '';  
      fourNumberController.text = carData['fourNumber'];
    } catch (error) {
      print('Error finding car: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding car. Please try again. $error')),
      );
    }
  }

  Future<void> _updateCarInfo() async {
    if (_formKey.currentState!.validate() && carRef != null) {
      final carUpdates = {
        'VehicleOwnerName': nameController.text,
        'VehicleNumber': plateController.text,
        'MobileNumber': numberController.text,
        'VehicleType': selectedType,
        'fourNumber': fourNumberController.text,
        'address': addressController.text,
        'make': makeController.text,
        'color': colorController.text,
        'driverName': driverNameController.text,
        'driverPhone': driverPhoneController.text,
      };

      try {
        await carRef!.update(carUpdates);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Car information updated successfully!')),
        );
        Navigator.pop(context);
      } catch (error) {
        print('Error updating car: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating car. Please try again.')),
        );
      }
    } else if (carRef == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please find a car to update first!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Car'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Wrap in SingleChildScrollView to handle potential overflow
          child: Column(
            children: [
              // Car number search field
              TextFormField(
                controller: carNumberController,
                decoration: InputDecoration(labelText: 'Car Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a car number' : null,
              ),
              SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: _findCarByNumber,
                child: Text('Find Car'),
              ),
              SizedBox(height: 16.0),
              Form(
                key: _formKey,
                child: carRef != null
                    ? Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                                labelText: 'Vehicle Owner Name'),
                            validator: (value) =>
                                value!.isEmpty ? 'Please enter a name' : null,
                          ),
                          TextFormField(
                            controller: plateController,
                            decoration:
                                InputDecoration(labelText: 'Vehicle Number'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a plate number'
                                : null,
                          ),
                          TextFormField(
                            controller: numberController,
                            decoration:
                                InputDecoration(labelText: 'Mobile Number'),
                            keyboardType: TextInputType.phone,
                            validator: (value) => value!.isEmpty
                                ? 'Please enter a mobile number'
                                : null,
                          ),
                          DropdownMenu(
                            initialSelection: list.first,
                            onSelected: (value) => setState(() {
                              selectedType = value!;
                            }),
                            dropdownMenuEntries:
                                list.map<DropdownMenuEntry<String>>((wheels) {
                              return DropdownMenuEntry(
                                  value: wheels, label: wheels);
                            }).toList(),
                          ),
                          TextFormField(
                            controller: addressController,
                            decoration: InputDecoration(labelText: 'Address'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter an address'
                                : null,
                          ),
                          TextFormField(
                            controller: makeController,
                            decoration: InputDecoration(labelText: 'Make'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter the car make'
                                : null,
                          ),
                          TextFormField(
                            controller: colorController,
                            decoration: InputDecoration(labelText: 'Color'),
                            validator: (value) => value!.isEmpty
                                ? 'Please enter the car color'
                                : null,
                          ),
                          TextFormField(
                            controller: driverNameController,
                            decoration: InputDecoration(
                                labelText: 'Driver Name (Optional)'),
                          ),
                          TextFormField(
                            controller: driverPhoneController,
                            decoration: InputDecoration(
                                labelText: 'Driver Phone (Optional)'),
                            keyboardType: TextInputType.phone,
                          ),
                          SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: _updateCarInfo,
                            child: Text('Update Car'),
                          ),
                        ],
                      )
                    : SizedBox(), // Show nothing if carRef is null
              ),
            ],
          ),
        ),
      ),
    );
  }
}
