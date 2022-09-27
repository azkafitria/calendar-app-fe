import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:calendar_app/pages/loading.dart';
import 'package:calendar_app/pages/calendar.dart';
import 'package:calendar_app/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "Calendar",
      initialRoute: '/loading',
      routes: {
        '/loading': (context) => const Loading(),
        '/': (context) => const Calendar(),
        '/login': (context) => const Login(),
      },
      builder: EasyLoading.init(),
    );
  }
}