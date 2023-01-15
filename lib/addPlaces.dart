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

class addPlaces extends StatefulWidget {
  const addPlaces({Key? key}) : super(key: key);

  @override
  State<addPlaces> createState() => _addPlacesState();
}

final _firestore = FirebaseFirestore.instance;

class _addPlacesState extends State<addPlaces> {
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
        .where("building", isEqualTo: "كلية العلوم")
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

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 400,
                height: 500,
                //margin: EdgeInsets.only(left: 15, top: 140),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage("$photo"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ElevatedButton(
                child: Text("Open Popup"),
                onPressed: () {
                  // print(photo);
                  _updateLocation();
                },
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    ;
                    FirebaseFirestore.instance
                        .collection('places')
                        .doc(selectedCat! +
                            '-' +
                            _placeNameEditingController.text)
                        .set({
                      "category": selectedCat,
                      'name': _placeNameEditingController.text,
                      'x': x,
                      "y": y
                    });
                  },
                  child: Text(
                    "حفظ",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ))
            ],
          ),
          //let's add the floating action button
        ]));
  }

  Widget dottedBorder({
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
          dashPattern: const [6.7],
          borderType: BorderType.RRect,
          color: color,
          radius: const Radius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: color,
                  size: 50,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: (() {
                      //_pickImage();
                    }),
                    child: Text(
                      "اضغط هنا لإضافة صورة الخريطة",
                    ))
              ],
            ),
          )),
    );
  }

  void _updateLocation() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            scrollable: true,
            title: Text(
              'اضافة موقع',
              style: TextStyle(color: Color.fromARGB(115, 40, 71, 185)),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                        maxLength: 20,
                        decoration: InputDecoration(
                          hintText: '...5G قاعة',
                          hintStyle: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 202, 198, 198)),
                          label: RichText(
                            text: TextSpan(
                                text: 'اسم الموقع',
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(144, 7, 32, 87)),
                                children: [
                                  TextSpan(
                                      text: ' *',
                                      style: TextStyle(
                                        color: Colors.red,
                                      ))
                                ]),
                          ),
                          labelStyle: TextStyle(
                              fontSize: 18,
                              color: Color.fromARGB(144, 7, 32, 87)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(144, 64, 7, 87),
                              width: 2.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(144, 7, 32, 87),
                              width: 2.0,
                            ),
                          ),
                        ),
                        controller: _placeNameEditingController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim() == '')
                            return 'required';
                          else if (!RegExp(r'^[a-z A-Z . , -]+$')
                                  .hasMatch(value!) &&
                              !RegExp(r'^[, . - أ-ي]+$').hasMatch(value!))
                            return "Only English or Arabic letters";
                        }),
                    DropdownButtonFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      hint: RichText(
                        text: TextSpan(
                            text: 'تصنيف الموقع ',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(144, 7, 32, 87)),
                            children: [
                              TextSpan(
                                  text: ' *',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ))
                            ]),
                      ),
                      items: options
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCat = value as String?;
                        });
                      },
                      icon: Icon(
                        Icons.arrow_drop_down_circle,
                        color: Color.fromARGB(221, 137, 171, 187),
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(144, 7, 32, 87),
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value == "") {
                          return 'required';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                  child: Text("اضافة"),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    ;
                    FirebaseFirestore.instance
                        .collection('places')
                        .doc(selectedCat! +
                            '-' +
                            _placeNameEditingController.text)
                        .set({
                      "category": selectedCat,
                      'name': _placeNameEditingController.text,
                      'x': 6,
                      "y": 8
                    });
                  })
            ],
          );
        });
  }
}
