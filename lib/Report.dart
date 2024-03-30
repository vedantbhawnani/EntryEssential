
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Reports extends StatefulWidget {
  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List<Map<String, dynamic>> _cars = [];

  @override
  void initState() {
    super.initState();
    _fetchcars();
  }

  Future<void> _fetchcars() async {
    final today = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('cars')
        .where('Time In',
            isGreaterThanOrEqualTo:
                DateTime(today.year, today.month, today.day))
        .where('Time In',
            isLessThanOrEqualTo:
                DateTime(today.year, today.month, today.day, 23, 59, 59))
        .get();
    setState(() {
      _cars = querySnapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Report'),
      ),
      body: _cars.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _cars.length,
              itemBuilder: (context, index) {
                final user = _cars[index];
                print(user);
                return ListTile(
                  title: Center(
                    child: Text(user['VehicleOwnerName'] ?? 'Unknown',
                        style: TextStyle(fontSize: 24)),
                  ), // Access user data
                  subtitle: Column(children: [
                    Text('Vehicle Number: ${user['VehicleNumber']}',
                        style: TextStyle(fontSize: 18)),
                    Text('Time In: ${user['Time In'].toDate()}',
                        style: TextStyle(fontSize: 18)),
                    user['Address'] != null
                        ? Text('Address: ${user['Address']}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "Address: ",
                            style: TextStyle(fontSize: 18),
                          ),
                    user['Make'] != null
                        ? Text('Vehicle Make: ${user['Make']}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "Vehicle Make: ",
                            style: TextStyle(fontSize: 18),
                          ),
                    user['Color'] != null
                        ? Text('Vehicle Color: ${user['Color']}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "Vehicle Color: ",
                            style: TextStyle(fontSize: 18),
                          ),
                    user['DriverName'] != null
                        ? Text('Driver Name: ${user['DriverName']}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "Driver Name: ",
                            style: TextStyle(fontSize: 18),
                          ),
                    user['DriverPhone'] != null
                        ? Text('Driver Phone: ${user['DriverPhone']}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "Driver Phone: ",
                            style: TextStyle(fontSize: 18),
                          ),
                    Text('Time In: ${user['Time In'].toDate()}',
                        style: TextStyle(fontSize: 18)),
                    user['Time Out'] != null
                        ? Text('Time Out: ${user['Time Out'].toDate()}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "Time Out: ",
                            style: TextStyle(fontSize: 18),
                          ),
                  ]),
                );
              },
            ),
    );
  }
}
