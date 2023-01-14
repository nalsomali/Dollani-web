import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web/login.dart';

class addMap extends StatefulWidget {
  const addMap({Key? key}) : super(key: key);

  @override
  State<addMap> createState() => _addMapState();
}

class _addMapState extends State<addMap> {
  //setting the expansion function for the navigation rail
  bool isExpanded = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          //Let's start by adding the Navigation Rail
          NavigationRail(
              extended: isExpanded,
              backgroundColor: Color.fromARGB(193, 49, 82, 192),
              unselectedIconTheme:
                  IconThemeData(color: Colors.white, opacity: 1),
              unselectedLabelTextStyle: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onDestinationSelected: (index) {
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => UserLogin()));
                  },
                );
              },
              selectedIconTheme:
                  IconThemeData(color: Color.fromARGB(255, 25, 54, 152)),
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.map_outlined),
                  label: Text("الخرائط"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text("الحساب"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  label: Text("تسجيل الخروج"),
                ),
              ],
              selectedIndex: 0),
        ],
      ),
      //let's add the floating action button
    );
  }
}
