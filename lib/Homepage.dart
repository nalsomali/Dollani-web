import 'package:web/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";

class HomeScreen extends StatefulWidget {
  static const String screenRoute = 'UserLogin';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
            leading: Row(
          children: [
            IconButton(
                icon: Icon(
                  Icons.logout,
                  color: Color.fromARGB(255, 45, 66, 142),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UserLogin()));
                })
          ],
        )));
  }
}
