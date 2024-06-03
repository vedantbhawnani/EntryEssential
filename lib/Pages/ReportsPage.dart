import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:rssb/Helper/Helper.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> _cars = [];
  int i = 1;

  @override
  void initState() {
    super.initState();
    if (DatabaseHelper.isInitialized) {
      _fetchcars();
    } else {
      DatabaseHelper.instance.initDatabase().then((_) {
        _fetchcars();
      });
    }
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
      for (var i = 0; i < _cars.length; i++) {
        _cars[i].update('TimeIn', (value) => value.toDate().toString());
        _cars[i]['TimeOut'] != null
            ? _cars[i].update('TimeOut', (value) => value.toDate().toString())
            : "";
        _cars[i].remove('MarkColor');
        _cars[i].remove('fourNumber');
        _cars[i].remove('DriverPhone');
        _cars[i].remove('Make');
        _cars[i].remove('Color');
      }
    });
  }

  Future<String> downloadFromDatabase() async {
    DateTime time = DateTime.now();
    final existingData = await DatabaseHelper.instance.database.query('cars');
    final newDataToSave = _cars.where((car) => !existingData.any((row) => row['VehicleNumber'] == car['VehicleNumber']));

    if (newDataToSave.isNotEmpty) {
      // Save only new or updated entries
      await DatabaseHelper.instance.saveToDatabase(newDataToSave.toList());
    }
    // await DatabaseHelper.instance.saveToDatabase(_cars);
    final directory = await getExternalStorageDirectory();
    final filename =
        '${time.year}-${time.month}-${time.day}-${time.hour}-${time.day}-${time.minute}-${time.second}';
    final path = join(directory!.path, 'Report-$filename.csv');
    final file = File(path);

    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    final csvData = StringBuffer();
    final header = [
      'VehicleNumber',
      'VehicleOwnerName',
      'MobileNumber',
      'Gate',
      'VehicleType',
      'TimeIn',
      'User'
    ];
    csvData.write(header.join(','));
    csvData.writeln();
    final results = await DatabaseHelper.instance.database.query('cars');
    for (var row in results) {
      print('Row $row');
      csvData.write([
        row['VehicleNumber'] ?? '',
        row['VehicleOwnerName'] ?? '',
        row['MobileNumber'] ?? '',
        row['Gate'] ?? '',
        row['VehicleType'] ?? '',
        row['TimeIn']?.toString() ?? '',
        row['User'] ?? ''
      ].join(','));
      csvData.writeln();
    }

    try {
      await file.writeAsString(csvData.toString());
    } catch (e) {
      print(e);
    }

    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => downloadFromDatabase().then((value) =>
                ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                  content: Text('File stored in $value'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(context)
                          .removeCurrentMaterialBanner(),
                      child: const Text('DISMISS'),
                    ),
                  ],
                ))),
          ),
        ],
      ),
      body: _cars.isEmpty
          ? const Center(child: Text('No entries yet.'))
          : ListView.builder(
              itemCount: _cars.length,
              itemBuilder: (context, index) {
                final user = _cars[index];
                print(user['Make']);
                return ListTile(
                  title: Center(
                    child: Text(user['VehicleOwnerName'] ?? 'Unknown',
                        style: const TextStyle(fontSize: 24)),
                  ),
                  subtitle: Column(
                    children: [
                      Text('Vehicle Number: ${user['VehicleNumber']}',
                          style: const TextStyle(fontSize: 18)),
                      Text('TimeIn: ${user['TimeIn'].toString()}',
                          style: const TextStyle(fontSize: 18)),
                      Text('Gate Number: ${user['Gate']}',
                          style: const TextStyle(fontSize: 18)),
                      if (user['Address'] != null)
                        Text('Address: ${user['Address']}',
                            style: const TextStyle(fontSize: 18)),
                      if (user['Make'] != null)
                        Text('Vehicle Make: ${user['Make']}',
                            style: const TextStyle(fontSize: 18)),
                      if (user['Color'] != null)
                        Text('Vehicle Color: ${user['Color']}',
                            style: const TextStyle(fontSize: 18)),
                      if (user['DriverName'] != null)
                        Text('DriverName: ${user['DriverName']}',
                            style: const TextStyle(fontSize: 18)),
                      if (user['DriverPhone'] != null)
                        Text('DriverPhone: ${user['DriverPhone']}',
                            style: const TextStyle(fontSize: 18)),
                      if (user['TimeOut'] != null)
                        Text('TimeOut: ${user['TimeOut']}',
                            style: const TextStyle(fontSize: 18)),
                      if (user['User'] != null)
                        Text('User: ${user['User']}',
                            style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
