import 'dart:io';
import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web/login.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web/loading_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
//import 'package:firebase_dart/firebase_dart.dart' as fb;
import 'package:firebase/firebase.dart' as fb;

import 'addHallways.dart';
import 'addMapsScreen.dart';
import 'addPlacesBackground.dart';
import 'editPlace.dart';
import 'maps.dart';
import 'places.dart';

class addNewPlace extends StatefulWidget {
  String mapName;
  //const addPlaces({Key? key}) : super(key: key);
  addNewPlace({required this.mapName});

  @override
  State<addNewPlace> createState() => _adNewPlacesState(mapName);
}

final _firestore = FirebaseFirestore.instance;

class _adNewPlacesState extends State<addNewPlace> {
  String mapName;
  _adNewPlacesState(this.mapName);

  //setting the expansion function for the navigation rail
  bool isExpanded = false;
  List<String> options = [];
  List<String> updated = [];
  List<String> admin = [];

  final TextEditingController _placeNameEditingController =
      TextEditingController();

  final TextEditingController buildingName = TextEditingController();
  final TextEditingController cat = TextEditingController();

  //late String category;
  late double x;
  late double y;
  String? selectedCat;
  String photo = '';

  void initState() {
    // call the methods to fetch the data from the DB
    getCategoryList();
    getMap();
    getPlaces();
    getAdminCategoryList();
    super.initState();
  }

  var placeName = [];
  var category = [];

  Future getPlaces() async {
    setState(() {
      placeName = [];
      category = [];
    });
    await for (var snapshot in FirebaseFirestore.instance
        .collection('places')
        .where('building', isEqualTo: mapName)
        .snapshots())
      for (var place in snapshot.docs) {
        setState(() {
          placeName.add(place['name']);
          category.add(place['category']);
        });
      }
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

  void getAdminCategoryList() async {
    final categories = await _firestore.collection('adminCategories').get();
    for (var category in categories.docs) {
      for (var element in category['categoriesP']) {
        setState(() {
          admin.add(element);
        });
      }
    }
  }

  Future getMap() async {
    await for (var snapshot in FirebaseFirestore.instance
        .collection('maps')
        .where("building", isEqualTo: mapName // we will replacet to mapName
            )
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserLogin()));
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
                child: Column(children: [
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
                    " تحديد المواقع على خريطة مبنى" + ": " + "$mapName",
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "تعليمات اضافة اماكن من خريطة",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 28, 51, 151)),
                  ),
                  Text(
                    " ١-لتحديد مكان من الخريطة الرجاء اختيار المكان المحدد اختيارة من صورة الخريطة   ",
                    style: TextStyle(
                        // fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 0, 0, 0)),
                    textAlign: TextAlign.right,
                  ),
                  Text(
                    "٢-عند تحديد المكان سيظهر لك نافذه يتم تحديد فيها اسم المكان ،تصنيفه",
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
                  ),
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
                  Container(
                    margin: EdgeInsets.only(right: 123),
                    child: Container(
                      height: 30,
                      width: 150,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 186, 187, 189),
                          ),
                          onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => places(
                                          mapName: mapName,
                                        )));
                          },
                          child: Text(
                            "العودة",
                            style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          )),
                    ),
                  )
                ],
              ),
            ])),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: Scrollbar(
                    thumbVisibility: true,
                    child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Color.fromARGB(255, 227, 227, 227)),
                        columns: [
                          DataColumn(label: Text("اسم الموقع")),
                          DataColumn(label: Text("تصنيف الموقع")),
                          // DataColumn(label: Text("حذف")),
                        ],
                        rows: [
                          for (var i = 0; i < placeName.length; i++)
                            DataRow(cells: [
                              DataCell(Text(placeName[i])),
                              DataCell(Text(category[i])),
                              // DataCell(TextButton(
                              //     onPressed: () {
                              //       CoolAlert.show(
                              //         context: context,
                              //         title: " حذف الموقع",
                              //         width: size.width * 0.2,
                              //         confirmBtnColor:
                              //             Color.fromARGB(181, 172, 22, 12),
                              //         showCancelBtn: false,
                              //         //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                              //         type: CoolAlertType.confirm,
                              //         backgroundColor:
                              //             Color.fromARGB(255, 45, 66, 142),
                              //         text: "هل تريد حذف الموقع",
                              //         confirmBtnText: 'حذف ',
                              //         cancelBtnText: "إلغاء",
                              //         onCancelBtnTap: () {
                              //           Navigator.pop(context);
                              //         },
                              //         onConfirmBtnTap: () async {
                              //           FirebaseFirestore.instance
                              //               .collection('places')
                              //               .doc(category[i] +
                              //                   "-" +
                              //                   placeName[i])
                              //               .delete();

                              //           Navigator.pop(context);
                              //         },
                              //       );
                              // },
                              // child: Icon(
                              //   Icons.delete,
                              //   color: Color.fromARGB(255, 74, 93, 188),
                              // )))
                            ]),
                        ]),
                  )),
                ],
              ),
            )
            //let's add the floating action button
          ]),
        ));
  }

  void _updateLocation(PointerEvent details) {
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
              'اضافة موقع',
              style: TextStyle(color: Color.fromARGB(115, 40, 71, 185)),
            ),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: _placeNameEditingController,
                      keyboardType: TextInputType.emailAddress,
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
                      validator: MultiValidator(
                          [RequiredValidator(errorText: 'مطلوب')]),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
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
                      validator: MultiValidator(
                          [RequiredValidator(errorText: 'مطلوب')]),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: cat,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'المطاعم، دورات المياه',
                        hintStyle: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 202, 198, 198)),
                        label: RichText(
                          text: TextSpan(
                            text:
                                'اذ لم تجد التصنيف المناسب الرجاء كتابة التصنيف',
                            style: const TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(144, 7, 32, 87)),
                          ),
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
                      // validator: MultiValidator(
                      //     [RequiredValidator(errorText: 'مطلوب')])),
                    )
                  ],
                ),
              ),
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
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  child: Text("اضافة"),
                  onPressed: () {
                    Navigator.pop(context);

                    if (_placeNameEditingController.text.isNotEmpty &&
                        selectedCat != null &&
                        selectedCat != "اخرى") {
                      FirebaseFirestore.instance
                          .collection('places')
                          .doc(selectedCat! +
                              '-' +
                              _placeNameEditingController.text)
                          .set({
                        "building": mapName,
                        "category": selectedCat,
                        'name': _placeNameEditingController.text,
                        'x': x,
                        "y": y
                      });

                      _placeNameEditingController.clear();
                      cat.clear();
                      CoolAlert.show(
                          context: context,
                          width: 120,
                          confirmBtnColor: Color.fromARGB(255, 45, 66, 142),
                          //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                          type: CoolAlertType.success,
                          backgroundColor: Color.fromARGB(255, 45, 66, 142),
                          text: "تم حفظ الاماكن بنجاح",
                          confirmBtnText: 'اغلاق',
                          showCancelBtn: false);
                    } else if (selectedCat == "اخرى" &&
                        _placeNameEditingController.text.isNotEmpty &&
                        cat.text.isNotEmpty &&
                        selectedCat != null) {
                      options.add(cat.text);
                      updated = options;
                      FirebaseFirestore.instance
                          .collection('categories')
                          .doc("MOGMaTOI7KLI4iB45cHb")
                          .update({
                        "categoriesP": updated,
                      });
                      FirebaseFirestore.instance
                          .collection('places')
                          .doc(
                              cat.text + '-' + _placeNameEditingController.text)
                          .set({
                        "building": mapName,
                        "category": cat.text,
                        'name': _placeNameEditingController.text,
                        'x': x,
                        "y": y
                      });
                      CoolAlert.show(
                          context: context,
                          width: 120,
                          confirmBtnColor: Color.fromARGB(255, 45, 66, 142),
                          //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                          type: CoolAlertType.success,
                          backgroundColor: Color.fromARGB(255, 45, 66, 142),
                          text: "تم حفظ الاماكن بنجاح",
                          confirmBtnText: 'اغلاق',
                          showCancelBtn: false);
                    } else {
                      CoolAlert.show(
                        context: context,
                        width: 130,
                        confirmBtnColor: Color.fromARGB(255, 45, 66, 142),
                        //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                        type: CoolAlertType.error,
                        backgroundColor: Color.fromARGB(255, 45, 66, 142),
                        text: "الرجاء ادخال جميع المعلومات المطلوبة عن الموقع",
                        confirmBtnText: 'اغلاق',
                        showCancelBtn: false,
                      );
                    }
                  })
            ],
          );
        });
  }
}
