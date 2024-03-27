import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart'; // for file path manipulation
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class ReportsPage extends StatefulWidget {
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> _cars = [];

  // SQLite database instance
  late Database database;

  @override
  void initState() {
    super.initState();
    _fetchcars();
    initDatabase();
  }

  Future<void> initDatabase() async {
    // Get a path to a directory where we can store our database file
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'ReportsPage.db');

    print(path);
    // Open the database or create it if it doesn't exist
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the cars table with appropriate columns
        await db.execute('''
  CREATE TABLE cars (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    VehicleOwnerName TEXT,
    VehicleNumber TEXT,
    VehicleType TEXT,
    TimeIn TEXT,
    Address TEXT,
    Make TEXT,
    Color TEXT,
    DriverName TEXT,
    DriverPhone TEXT,
    TimeOut TEXT,
    fourNumber TEXT,
    MarkColor TEXT,
  )
''');
      },
    );
    print('table created');
  }

  Future<void> _fetchcars() async {
    final today = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    final querySnapshot = await firestore
        .collection('cars')
        .where('TimeIn',
            isGreaterThanOrEqualTo:
                DateTime(today.year, today.month, today.day))
        .where('TimeIn',
            isLessThanOrEqualTo:
                DateTime(today.year, today.month, today.day, 23, 59, 59))
        .get();
    setState(() {
      _cars = querySnapshot.docs.map((doc) => doc.data()).toList();
      print(_cars);
      _cars[0].update(
        'TimeIn',
        (value) => value.toDate().toString(),
      ); // Add comma if required
      _cars[0]['TimeOut'] != null
          ? _cars[0].update('TimeOut', (value) => value.toDate().toString())
          : "";
      _cars[0]['MarkColor'] = "";
    });
    await initDatabase();
    await saveToDatabase(_cars);
  }

  Future<void> saveToDatabase(List<Map<String, dynamic>> cars) async {
    for (var user in cars) {
      final data = Map<String, dynamic>.from(user); // Create a copy
      data.removeWhere(
          (key, value) => value == null); // Remove null key-value pairs
      print('SQL Query: INSERT OR REPLACE INTO cars (...) VALUES (...)');

      await database.insert(
        'cars',
        data,
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Update if already exists
      );
    }
  }

  Future<void> downloadFromDatabase() async {
    final directory = await getExternalStorageDirectory();
    final filename = DateTime.now().toString() + '.csv';
    final path = join(directory!.path, filename);
    final file = File(path);

    // Request storage permission if needed
    await Permission.storage.request();

    final csvData = StringBuffer();
    final header = [
      'VehicleOwnerName',
      'VehicleNumber',
      'TimeIn',
      'Address',
      'Make',
      'Color',
      'DriverName',
      'DriverPhone',
      'TimeOut',
    ];
    csvData.write(header.join(','));
    csvData.writeln();
    final results = await database.query('cars');
    for (var row in results) {
      // Use comma-separated string interpolation for each row
      csvData.write('''
      ${row['VehicleOwnerName'] ?? ''},
      ${row['VehicleNumber'] ?? ''},
      ${row['TimeIn']?.toString() ?? ''},
      ${row['Address'] ?? ''},
      ${row['Make'] ?? ''},
      ${row['Color'] ?? ''},
      ${row['DriverName'] ?? ''},
      ${row['DriverPhone'] ?? ''},
      ${row['TimeOut']?.toString() ?? ''}
      ''');
    }

    await file.writeAsString(csvData.toString());

    print('Report download');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => downloadFromDatabase(),
          ),
        ], // Add download button to action bar
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
                    // Text('TimeIn: ${user['TimeIn']}',
                    //     style: TextStyle(fontSize: 18)),
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
                    Text('TimeIn: ${user['TimeIn']}',
                        style: TextStyle(fontSize: 18)),
                    user['TimeOut'] != null
                        ? Text('TimeOut: ${user['TimeOut']}',
                            style: TextStyle(fontSize: 18))
                        : Text(
                            "TimeOut: ",
                            style: TextStyle(fontSize: 18),
                          ),
                  ]),
                );
              },
            ),
    );
  }
}
