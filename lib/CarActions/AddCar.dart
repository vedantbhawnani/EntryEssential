import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddCarPage extends StatefulWidget {
  const AddCarPage({super.key});

  @override
  _AddCarPage createState() => _AddCarPage();
}

class _AddCarPage extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();

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

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> list = ['2-wheeler', '3-wheeler', '4-wheeler'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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

  Future<void> _addCarToFirebase() async {
    if (_formKey.currentState!.validate()) {
      final userInfo = {
        'VehicleOwnerName': nameController.text,
        'VehicleNumber': plateController.text,
        'MobileNumber': numberController.text,
        'VehicleType': selectedType,
        'fourNumber': fourNumberController.text.isEmpty
            ? null
            : fourNumberController.text,
        'address': addressController.text.isEmpty
            ? null
            : addressController.text,
        'make':
            makeController.text.isEmpty ? null : makeController.text,
        'color':
            colorController.text.isEmpty ? null : colorController.text,
        'driverName': driverNameController.text.isEmpty
            ? null
            : driverNameController.text,
        'driverPhone': driverPhoneController.text.isEmpty
            ? null
            : driverPhoneController.text,
      };

      try {
        await firestore.collection('cars').add(userInfo);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: const Text('Car added successfully!')),
        );

        Navigator.pop(context);
      } catch (error) {
        print('Error adding car: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding car. Please try again. $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Car'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Vehicle Owner Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: plateController,
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a plate number' : null,
              ),
              DropdownButtonFormField(
                value: selectedType.isEmpty ? list.first : selectedType,
                items: list
                    .map<DropdownMenuItem<String>>((wheels) => DropdownMenuItem(
                          value: wheels,
                          child: Text(wheels),
                        ))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedType = value as String),
                decoration: const InputDecoration(labelText: 'Vehicle Type'),
              ),
              TextFormField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              TextFormField(
                controller: fourNumberController,
                decoration: const InputDecoration(labelText: 'Last Four Number'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address (Optional)'),
              ),
              TextFormField(
                controller: makeController,
                decoration: const InputDecoration(labelText: 'Make (Optional)'),
              ),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(labelText: 'Color (Optional)'),
              ),
              TextFormField(
                controller: driverNameController,
                decoration:
                    const InputDecoration(labelText: 'Driver Name (Optional)'),
              ),
              TextFormField(
                controller: driverPhoneController,
                decoration:
                    const InputDecoration(labelText: 'Driver Phone (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addCarToFirebase,
                child: const Text('Add Car'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
