import 'package:flutter/material.dart';

import 'package:calendar_app/constants/constants.dart';


class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  LoadingState createState() => LoadingState();
}

class LoadingState extends State<Loading> {
  late String token;

  void checkToken() async {
    await getToken().then((value) => token = value ?? '');
    print("$token");
    if (token.isEmpty) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  void initState() {
    super.initState();
    checkToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Text(
                'CalendarApp',
                style: TextStyle(
                  color: Colors.lightGreen[900],
                  fontSize: 48,
                  fontWeight: FontWeight.bold
                )
            )
        )
    );
  }
}