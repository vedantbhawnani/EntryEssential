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
          Spacer(),
          Center(child: Text('Admin Access', style: TextStyle(fontSize: 25))),
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
                              builder: (context) => AddCarPage()));
                    },
                    child: Text('Add Car')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateCarPage()));
                    },
                    child: Text('Update Car')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DeleteCarPage()));
                    },
                    child: Text('Delete Car')),
                // Spacer(),
              ]),
          ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddUserPage()));
              },
              child: Text('Add user')),
          Spacer(
            flex: 2,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Confirm Reset'),
              content: Text(
                  'Are you sure you want to reset Firebase values and the local database table? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: (() async {
                    await DatabaseHelper.instance
                        .resetFirebaseValues()
                        .then((value) => DatabaseHelper.instance.resetTable())
                        .then((value) =>
                            DatabaseHelper.instance.resetGateCounts())
                        .then((value) =>
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Values resetted.'),
                              behavior: SnackBarBehavior.floating,
                            )))
                        .then((value) => Navigator.pop(context));
                  }),
                  child: Text('Reset'),
                ),
              ],
            ),
          );
        },
        child: Icon(CupertinoIcons.refresh_thick),
      ),
    );
  }
}
