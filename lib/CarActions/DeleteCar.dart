import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DeleteCarPage extends StatefulWidget {
  @override
  _DeleteCarPageState createState() => _DeleteCarPageState();
}

class _DeleteCarPageState extends State<DeleteCarPage> {
  // final _formKey = GlobalKey<FormState>();

  String carRef = "";

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final carNumberController = TextEditingController();
  final nameController = TextEditingController();
  final plateController = TextEditingController();
  final numberController = TextEditingController();
  var selectedType = '';
  final addressController = TextEditingController();
  final makeController = TextEditingController();
  final colorController = TextEditingController();
  final driverNameController = TextEditingController();
  final driverPhoneController = TextEditingController();
  final fourNumberController = TextEditingController();
  bool display = false;
  @override
  void initState() {
    super.initState();
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
      return; // Handle empty car number
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

      DocumentSnapshot carData =
          snapshot.docs[0]; // Assuming only one car with the number
      carRef = carData.id; // Set car reference for update

      nameController.text = carData['VehicleOwnerName'];
      plateController.text = carData['VehicleNumber'];
      selectedType = carData['VehicleType'] ?? "";
      numberController.text = carData['MobileNumber'] ?? "";
      setState(() {
        display = true;
      });
    } catch (error) {
      print('Error finding car: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding car. Please try again.')),
      );
    }
  }

  Future<void> _deleteCar() async {
    try {
      firestore
          .collection('cars')
          .doc(carRef)
          .delete()
          .then((value) => print("User Deleted"))
          .catchError((error) => print("Failed to delete user: $error"))
          .then((value) => Navigator.pop(
              context)); // Close the page after successful deletion
    } catch (error) {
      print('Error deleting car: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting car. Please try again.')),
      );
    } finally {
      carRef = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    print('$makeController');

    return Scaffold(
      appBar: AppBar(
        title: Text('Delete Car'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
              Visibility(
                visible: display,
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200, // Light grey background
                    borderRadius:
                        BorderRadius.circular(10.0), // Rounded corners
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align content to the left
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceBetween, // Space labels evenly
                        children: [
                          Text(
                            'Owner Name:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(nameController.text),
                        ],
                      ),
                      SizedBox(height: 10.0), // Add some vertical spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vehicle Number:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(plateController.text),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      makeController.text != ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Vehicle Make:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(makeController.text),
                              ],
                            )
                          : Container(),
                      colorController.text != ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Vehicle Color:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(colorController.text),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: carRef != ""
                    ? _deleteCar
                    : null, // Disable if carRef is null
                child: Text('Delete Car'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Use red color for confirmation
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
