// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'HomePage.dart';
import 'SignUp.dart';
import 'credentials.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: Text(
            'Login Page',
            style: TextStyle(letterSpacing: 1.0),
          )),
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 50, right: 50, bottom: 20, top: 10),
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                          labelText: 'User Name',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green))),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(
                          left: 50, right: 50, bottom: 20, top: 10),
                      child: TextField(
                        obscureText: true,
                        controller: passwordController,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.green))),
                      )),
                  ElevatedButton(
                      onPressed: () async {
                        var username = nameController.text;
                        var password = passwordController.text;
                        if (credentials.containsKey(username) &&
                            credentials[username] == password) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        } else {
                          // Text('Incorrect User Name/Password');
                          nameController.text = "";
                          passwordController.text = "";
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          minimumSize: Size(90, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text("Login!")),
                  SizedBox(
                    height: 200,
                  ),
                  TextButton(
                      onPressed: () async {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text("New User? Sign up")),
                ],
              ),
            ),
          )),
    );
  }
}
