import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

const String beUrl = 'https://agile-depths-39296.herokuapp.com';

const storage = FlutterSecureStorage();

Future<String?> getToken() async {
  return await storage.read(key: 'token');
}

Future<void> storeToken(token) async {
  await storage.write(key: 'token', value: token);
}

showSnackBar(context, text) {
  var snackBar = SnackBar(content: Text(text));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}