import 'package:cool_alert/cool_alert.dart';
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
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Row(
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Color.fromARGB(255, 45, 66, 142),
                    ),
                    onPressed: () {
                      CoolAlert.show(
                        context: context,
                        title: "تسجيل الخروج",
                        width: size.width * 0.2,
                        confirmBtnColor: Color.fromARGB(181, 172, 22, 12),
                        showCancelBtn: false,
                        //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                        type: CoolAlertType.confirm,
                        backgroundColor: Color.fromARGB(255, 45, 66, 142),
                        text: "هل تريد تسجيل الخروج",
                        confirmBtnText: 'تسجيل الخروج',
                        cancelBtnText: "إلغاء",
                        onCancelBtnTap: () {
                          Navigator.pop(context);
                        },
                        onConfirmBtnTap: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UserLogin()));
                        },
                      );
                    })
              ],
            )));
  }
}
