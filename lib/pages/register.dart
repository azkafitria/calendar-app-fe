import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:calendar_app/pages/login.dart';
import 'package:calendar_app/constants/constants.dart';
import 'package:calendar_app/pages/calendar.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  ResgiterState createState() => ResgiterState();
}

class ResgiterState extends State<Register> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 100.0, 25, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'CalendarApp',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightGreen[900]!),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Register',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder:OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[500]!, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Username'
                  ),
                  cursorColor: Colors.grey,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder:OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[500]!, width: 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Email'
                  ),
                  cursorColor: Colors.grey,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder:OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey[500]!, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: 'Password',
                  ),
                  cursorColor: Colors.grey,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20)),
                  child: TextButton(
                    onPressed: () async {
                      Map data = {
                        "username": usernameController.text,
                        "email": emailController.text,
                        "password": passwordController.text
                      };
                      final response = await http.post(Uri.parse('$beUrl/api/auth/local/register'),
                          headers: <String, String> {
                            'content-type': 'application/json',
                          },
                          body: json.encode(data)
                      );
                      var bodyResponse = json.decode(response.body);
                      if (response.statusCode == 200) {
                        var token = bodyResponse['jwt'];
                        storeToken(token);
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Calendar()));
                      } else {
                        showSnackBar(context, bodyResponse['error']['message']);

                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextButton(
                      child: Text(
                        'Login',
                        style: TextStyle(color: Colors.lightGreen[900]!),
                      ),
                      onPressed: () async {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Login()));
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}