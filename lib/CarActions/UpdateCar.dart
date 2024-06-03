import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateCarPage extends StatefulWidget {
  const UpdateCarPage({super.key});

  @override
  _UpdateCarPageState createState() => _UpdateCarPageState();
}

class _UpdateCarPageState extends State<UpdateCarPage> {
  // Define TextEditingControllers to hold car information
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController vehicleOwnerNameController =
      TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController makeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController driverPhoneController = TextEditingController();
  final TextEditingController fourNumberController = TextEditingController();

  String _vehicleType = "";
  String _docId = "";
  bool _showResult = false; // Flag to control visibility
  List<String> list = <String>['2-wheeler', '3-wheeler', '4-wheeler'];
  Map<String, dynamic> userInfo = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Car'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: vehicleNumberController,
                decoration:
                    const InputDecoration(labelText: 'Search Vehicle Number'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a vehicle number';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (vehicleNumberController.text.isNotEmpty) {
                    getCarData(vehicleNumberController.text);
                    setState(() => _showResult = true);
                  }
                },
                child: const Text('Search Car'),
              ),
              Visibility(
                visible: _showResult,
                child: Column(
                  children: [
                    TextFormField(
                      controller: vehicleOwnerNameController,
                      decoration: const InputDecoration(
                          labelText: 'Vehicle Owner Name'),
                    ),
                    TextFormField(
                      controller: mobileNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Mobile Number'),
                    ),
                    TextFormField(
                      controller: fourNumberController,
                      decoration:
                          const InputDecoration(labelText: 'Last Four Numbers'),
                    ),
                    DropdownButtonFormField(
                      value: _vehicleType.isEmpty ? list.first : _vehicleType,
                      items: list
                          .map<DropdownMenuItem<String>>(
                              (wheels) => DropdownMenuItem(
                                    value: wheels,
                                    child: Text(wheels),
                                  ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _vehicleType = value as String),
                      decoration:
                          const InputDecoration(labelText: 'Vehicle Type'),
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                    ),
                    TextFormField(
                      controller: makeController,
                      decoration: const InputDecoration(labelText: 'Make'),
                    ),
                    TextFormField(
                      controller: colorController,
                      decoration: const InputDecoration(labelText: 'Color'),
                    ),
                    TextFormField(
                      controller: driverNameController,
                      decoration:
                          const InputDecoration(labelText: 'Driver Name'),
                    ),
                    TextFormField(
                      controller: driverPhoneController,
                      decoration:
                          const InputDecoration(labelText: 'Driver Phone'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        updateData();
                      },
                      child: const Text('Update Car'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void getCarData(String number) async {
    try {
      final collection = FirebaseFirestore.instance.collection('cars');
      final querySnapshot =
          await collection.where('VehicleNumber', isEqualTo: number).get();

      if (querySnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No car found with number: $number"),
          ),
        );
        return;
      }

      final vehicleData = querySnapshot.docs[0].data();
      final docId = querySnapshot.docs[0].reference.id;

      setState(() {
        vehicleOwnerNameController.text = vehicleData['VehicleOwnerName'];
        mobileNumberController.text = vehicleData['MobileNumber'] ?? "";
        _vehicleType = vehicleData['VehicleType'] ?? "";
        addressController.text = vehicleData['Address'] ?? "";
        makeController.text = vehicleData['Make'] ?? "";
        colorController.text = vehicleData['Color'] ?? "";
        driverNameController.text = vehicleData['DriverName'] ?? "";
        driverPhoneController.text = vehicleData['DriverPhone'] ?? "";
        fourNumberController.text = vehicleData['fourNumber'] ?? "";
        _docId = docId;
      });

      print(vehicleData);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error getting car data: $error"),
        ),
      );
    }
  }

  Future<void> updateData() async {
    final userInfo = {
      'VehicleOwnerName': vehicleOwnerNameController.text,
      'VehicleNumber': vehicleNumberController.text,
      'MobileNumber': mobileNumberController.text,
      'VehicleType': _vehicleType,
      'Address': addressController.text,
      'Make': makeController.text,
      'Color': colorController.text,
      'DriverName': driverNameController.text,
      'DriverPhone': driverPhoneController.text,
      'fourNumber': fourNumberController.text
    };
    try {
      await FirebaseFirestore.instance
          .collection('cars')
          .doc(_docId)
          .update(userInfo)
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text('Updated Successfully'),
                ),
              ))
          .then((value) => Navigator.pop(context));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('ERror $error'),
        ),
      );
    }
  }
}
