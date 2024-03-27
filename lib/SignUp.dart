// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:rssb/LoginPage.dart';
import 'package:rssb/credentials.dart';

import 'HomePage.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: Text(
            'Sign Up',
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
                        keyboardType: TextInputType.emailAddress,
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'User Name',
                          border: OutlineInputBorder(),
                        )),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 50, right: 50, bottom: 20, top: 10),
                    child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                        )),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        credentials.addEntries({
                          nameController.text: passwordController.text
                        }.entries);
                        // Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => HomePage()));
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          minimumSize: Size(90, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30))),
                      child: Text("Register!")),
                  SizedBox(
                    height: 200,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()));
                      },
                      child: Text("Existing User? Sign in")),
                ],
              ),
            ),
          )),
    );
  }
}
