import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rssb/Pages/HomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final username = usernameController.text;
      final password = passwordController.text;

      try {
        final credentialsCollection =
            FirebaseFirestore.instance.collection('credentials');
        final docSnapshot = await credentialsCollection.doc(username).get();

        if (docSnapshot.exists) {
          final storedUsername = docSnapshot.data()!['username'];
          final storedHashedPassword = docSnapshot.data()!['hashedPassword'];

          if (username != storedUsername) {
            throw Exception('Username does not match.');
          }

          final hashedPassword = await _hashPassword(password);

          if (hashedPassword != storedHashedPassword) {
            throw Exception('Incorrect password.');
          }

          await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: '$username@gmail.com', password: password); //

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login successful!')),
          );

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: ((context) => HomePage(name: username))));
        } else {
          throw Exception('Username not found.');
        }
      } on Exception catch (error) {
        print('Error logging in user: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    }
  }

  Future<String> _hashPassword(String password) async {
    return 'hashed_$password';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a username' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _loginUser,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
