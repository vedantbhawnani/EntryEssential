// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rssb/CarActions/AddCar.dart';
import 'package:rssb/CarActions/DeleteCar.dart';
import 'package:rssb/CarActions/UpdateCar.dart';

import '../Helper/Helper.dart';
import 'Login/SignUp.dart';

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
  TextEditingController fourNumberController = TextEditingController();
  Map<String, dynamic> userInfo = {};

  @override
  Widget build(BuildContext context) {
    // String selectedType = list.first;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Spacer(),
          const Center(child: Text('Admin Access', style: TextStyle(fontSize: 25))),
          Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Spacer(),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AddCarPage()));
                    },
                    child: const Text('Add Car')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UpdateCarPage()));
                    },
                    child: const Text('Update Car')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DeleteCarPage()));
                    },
                    child: const Text('Delete Car')),
                // Spacer(),
              ]),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddUserPage()));
              },
              child: const Text('Add user')),
          const Spacer(
            flex: 2,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirm Reset'),
              content: const Text(
                  'Are you sure you want to reset Firebase values and the local database table? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: (() async {
                    await DatabaseHelper.instance
                        .resetFirebaseValues()
                        .then((value) => DatabaseHelper.instance.resetTable())
                        .then((value) =>
                            DatabaseHelper.instance.resetGateCounts())
                        .then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Values resetted.'),
                              behavior: SnackBarBehavior.floating,
                            )))
                        .then((value) => Navigator.pop(context));
                  }),
                  child: const Text('Reset'),
                ),
              ],
            ),
          );
        },
        child: const Icon(CupertinoIcons.refresh_thick),
      ),
    );
  }
}
