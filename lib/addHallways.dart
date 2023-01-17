import 'dart:io';
import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web/login.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web/loading_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
//import 'package:firebase_dart/firebase_dart.dart' as fb;
import 'package:firebase/firebase.dart' as fb;

import 'addMapsScreen.dart';
import 'maps.dart';

class addHallways extends StatefulWidget {
  String mapName;
  //const addPlaces({Key? key}) : super(key: key);
  addHallways({required this.mapName});

  @override
  State<addHallways> createState() => _addHallwaysState(mapName);
}

final _firestore = FirebaseFirestore.instance;

class _addHallwaysState extends State<addHallways> {
  String mapName;
  _addHallwaysState(this.mapName);
  bool isExpanded = false;
  List<String> options = [];
  final TextEditingController _placeNameEditingController =
      TextEditingController();
  final TextEditingController buildingName = TextEditingController();
  late double xStart;
  late double yStart;
  late double xEnd;
  late double yEnd;
  String photo = '';

  void initState() {
    getMap();
    super.initState();
  }

  bool isSelected = false;

  Future getMap() async {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('maps')
        .where("building", isEqualTo: mapName)
        .snapshots())
      for (var map in snapshot.docs) {
        setState(() {
          photo = map['floor plan'].toString();
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        body: Row(children: [
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
                if (index == 0)
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardScreen()));
                if (index == 1)
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => addMaps()));
                if (index == 2)
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
                  icon: Icon(Icons.add_location_alt_outlined),
                  label: Text("اضافة خريطة جديدة"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  label: Text("تسجيل الخروج"),
                ),
              ],
              selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        //let's trigger the navigation expansion
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      icon: Icon(Icons.menu),
                    ),
                    Text(
                      " تحديد الممرات على خريطة مبنى" + ": " + "$mapName",
                      style: TextStyle(
                          fontSize: 30,
                          //  fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 23, 39, 112)),
                    ),
                    Image.asset(
                      'assets/images/logo.png',
                      scale: 7,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "تعليمات اضافة ممرات على خريطة",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 28, 51, 151)),
                        ),
                        Text(
                          " ١-لتحديد ممر من الخريطة الرجاء اختيار نقطة بداية الممر المحدد اختياره من صورة الخريطة   ",
                          style: TextStyle(
                              // fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          "٢-عند تحديد نقطة البداية ستظهر لك نافذه يتم فيها تأكيد النقطة",
                          style: TextStyle(
                              //fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          "٣-الرجاء ادخال نقطة النهايه بنفس الطريقة  والنقر على اضافة .                            ",
                          style: TextStyle(
                              //   fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          textAlign: TextAlign.right,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Listener(
                          // cursor: SystemMouseCursors.click,
                          onPointerMove: isSelected == false
                              ? _updateLocation
                              : _updateLocation2,
                          child: Container(
                            width: 400,
                            height: 530,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage("$photo"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 30,
                          width: 150,
                          child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 45, 66, 142),
                              ),
                              onPressed: () async {
                                FirebaseFirestore.instance
                                    .collection('hallways')
                                    .add({
                                  "building": mapName,
                                  'xStart': xStart.round(),
                                  "yStart": yStart.round(),
                                  'xEnd': xEnd.round(),
                                  "yEnd": yEnd.round(),
                                });
                                CoolAlert.show(
                                  context: context,
                                  width: size.width * 0.2,
                                  confirmBtnColor:
                                      Color.fromARGB(255, 45, 66, 142),
                                  //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                                  type: CoolAlertType.success,
                                  backgroundColor:
                                      Color.fromARGB(255, 45, 66, 142),
                                  text: "تم حفظ الممر بنجاح",
                                  confirmBtnText: 'اغلاق',
                                  onConfirmBtnTap: () {
                                    _placeNameEditingController.clear();

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                DashboardScreen()));
                                  },
                                );
                              },
                              child: Text(
                                "حفظ",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              )),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ]));
  }

  void _updateLocation(PointerEvent details) {
    isSelected = true;

    setState(() {
      xStart = details.position.dx;
      yStart = details.position.dy;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'اضافة نقطة بداية ',
              style: TextStyle(color: Color.fromARGB(115, 40, 71, 185)),
            ),
            actions: [
              ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  child: Text("اضافة"),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  void _updateLocation2(PointerEvent details) {
    setState(() {
      xEnd = details.position.dx;
      yEnd = details.position.dy;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'اضافة نقطة نهاية',
              style: TextStyle(color: Color.fromARGB(115, 40, 71, 185)),
            ),
            actions: [
              ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  child: Text("اضافة"),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }
}
