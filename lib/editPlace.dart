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
import 'package:web/places.dart';

import 'addMapsScreen.dart';
import 'addPlacesBackground.dart';
import 'maps.dart';

class editPlaces extends StatefulWidget {
  String mapName;
  String Map;
  //const addPlaces({Key? key}) : super(key: key);
  editPlaces({required this.mapName, required this.Map});

  @override
  State<editPlaces> createState() => _editPlacesState(mapName, Map);
}

final _firestore = FirebaseFirestore.instance;

class _editPlacesState extends State<editPlaces> {
  String mapName;
  String Map;
  _editPlacesState(this.mapName, this.Map);

  //setting the expansion function for the navigation rail
  bool isExpanded = false;
  List<String> options = [];
  final TextEditingController _placeNameEditingController =
      TextEditingController();
  final TextEditingController buildingName = TextEditingController();
  //late String category;
  late double x;
  late double y;
  String? selectedCat;
  String photo = '';

  void initState() {
    // call the methods to fetch the data from the DB
    getCategoryList();
    getMap();
    getplace();
    super.initState();
  }

  void getCategoryList() async {
    final categories = await _firestore.collection('categories').get();
    for (var category in categories.docs) {
      for (var element in category['categoriesP']) {
        setState(() {
          options.add(element);
        });
      }
    }
  }

  Future getMap() async {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('maps')
        .where("building", isEqualTo: Map)
        .snapshots())
      for (var map in snapshot.docs) {
        setState(() {
          photo = map['floor plan'].toString();
        });
      }
  }

  String category = "";
  String name = "";
  Future getplace() async {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('places')
        .where("building", isEqualTo: Map // we will replace it to mapName
            )
        .where("name", isEqualTo: mapName // we will replace it to mapName
            )
        .snapshots())
      for (var map in snapshot.docs) {
        setState(() {
          category = map['category'].toString();
          name = map['name'].toString();
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Colors.white,
        body: addPlacesBackground(
            child: Row(children: [
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
                      " تعديل موقع " + "$mapName" + " على الخريطة ",
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
                          "تعليمات تعديل موقع من خريطة",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 28, 51, 151)),
                        ),
                        Text(
                          " ١-لتحديد موقع من الخريطة الرجاء اختيار المكان المحدد واختياره من صورة الخريطة   ",
                          style: TextStyle(
                              // fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          "٢-عند تحديد المكان ستظهر لك نافذه يتم تحديد فيها اسم الموقع و تصنيفه",
                          style: TextStyle(
                              //fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 0, 0, 0)),
                          textAlign: TextAlign.right,
                        ),
                        Text(
                          "٣-الرجاء ادخال البيانات المطلوبة والنقر على اضافة .                            ",
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
                          onPointerMove: _updateLocation,
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
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 150,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 186, 187, 189),
                                  ),
                                  onPressed: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => places(
                                                  mapName: Map,
                                                )));
                                  },
                                  child: Text(
                                    "السابق",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  )),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              height: 30,
                              width: 150,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 45, 66, 142),
                                  ),
                                  onPressed: () async {
                                    FocusScope.of(context).unfocus();
                                    FirebaseFirestore.instance
                                        .collection('places')
                                        .doc(category + '-' + name)
                                        .update({'x': x, "y": y});

                                    CoolAlert.show(
                                      title: " تعديل الموقع",
                                      context: context,
                                      width: size.width * 0.2,
                                      confirmBtnColor:
                                          Color.fromARGB(255, 45, 66, 142),
                                      //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                                      type: CoolAlertType.success,
                                      backgroundColor:
                                          Color.fromARGB(255, 45, 66, 142),
                                      text: "تم تعديل الموقع بنجاح",
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
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          //let's add the floating action button
        ])));
  }

  void _updateLocation(PointerEvent details) {
    Size size = MediaQuery.of(context).size;

    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              scrollable: true,
              title: Text(
                'تعديل موقع $mapName',
                style: TextStyle(color: Color.fromARGB(227, 19, 49, 158)),
              ),
              actions: [
                ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 175, 177, 180),
                    ),
                    child: Text("الغاء"),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    }),
                ElevatedButton(
                    child: Text("تعديل"),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      ;

                      Navigator.pop(context);
                    }),
              ]
              // content: Padding(
              //   padding: const EdgeInsets.all(8.0),
              // child: Form(
              //   child: Column(
              //     children: <Widget>[
              // TextFormField(
              //           maxLength: 20,
              //           decoration: InputDecoration(
              //             hintText: '...5G قاعة',
              //             hintStyle: TextStyle(
              //                 fontSize: 16,
              //                 color: Color.fromARGB(255, 202, 198, 198)),
              //             label: RichText(
              //               text: TextSpan(
              //                   text: 'اسم الموقع',
              //                   style: const TextStyle(
              //                       fontSize: 18,
              //                       color: Color.fromARGB(144, 7, 32, 87)),
              //                   children: [
              //                     TextSpan(
              //                         text: ' *',
              //                         style: TextStyle(
              //                           color: Colors.red,
              //                         ))
              //                   ]),
              //             ),
              //             labelStyle: TextStyle(
              //                 fontSize: 18,
              //                 color: Color.fromARGB(144, 7, 32, 87)),
              //             border: OutlineInputBorder(
              //               borderSide: BorderSide(
              //                 color: Color.fromARGB(144, 64, 7, 87),
              //                 width: 2.0,
              //               ),
              //             ),
              //             focusedBorder: OutlineInputBorder(
              //               borderSide: BorderSide(
              //                 color: Color.fromARGB(144, 7, 32, 87),
              //                 width: 2.0,
              //               ),
              //             ),
              //           ),
              //           controller: _placeNameEditingController,
              //           validator: (value) {
              //             if (value == null ||
              //                 value.isEmpty ||
              //                 value.trim() == '')
              //               return 'required';
              //             else if (!RegExp(r'^[a-z A-Z . , -]+$')
              //                     .hasMatch(value!) &&
              //                 !RegExp(r'^[, . - أ-ي]+$').hasMatch(value!))
              //               return "Only English or Arabic letters";
              //           }),
              //       DropdownButtonFormField(
              //         autovalidateMode: AutovalidateMode.onUserInteraction,
              //         hint: RichText(
              //           text: TextSpan(
              //               text: 'تصنيف الموقع ',
              //               style: const TextStyle(
              //                   fontSize: 18,
              //                   color: Color.fromARGB(144, 7, 32, 87)),
              //               children: [
              //                 TextSpan(
              //                     text: ' *',
              //                     style: TextStyle(
              //                       color: Colors.red,
              //                     ))
              //               ]),
              //         ),
              //         items: options
              //             .map((e) => DropdownMenuItem(
              //                   value: e,
              //                   child: Text(e),
              //                 ))
              //             .toList(),
              //         onChanged: (value) {
              //           setState(() {
              //             selectedCat = value as String?;
              //           });
              //         },
              //         icon: Icon(
              //           Icons.arrow_drop_down_circle,
              //           color: Color.fromARGB(221, 137, 171, 187),
              //         ),
              //         decoration: InputDecoration(
              //           border: OutlineInputBorder(
              //             borderSide: BorderSide(width: 2.0),
              //           ),
              //           focusedBorder: OutlineInputBorder(
              //             borderSide: BorderSide(
              //               color: Color.fromARGB(144, 7, 32, 87),
              //               width: 2.0,
              //             ),
              //           ),
              //         ),
              //         validator: (value) {
              //           if (value == null || value == "") {
              //             return 'required';
              //           }
              //         },
              //       ),
              //     ],
              //   ),
              // ),
              //   ),
              );
        });
  }
}
