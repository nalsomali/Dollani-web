import 'dart:html';
import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'addMapBackground.dart';
import 'addPlaces.dart';
import 'login.dart';
import 'maps.dart';

class addMaps extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Uint8List webImage = Uint8List(8);

class _HomeState extends State<addMaps> {
  final TextEditingController buildingName = TextEditingController();
  late String building = "";
  late String height = "";
  late String width = "";

  final TextEditingController buildingHeight = TextEditingController();
  final TextEditingController buildingWidth = TextEditingController();

  bool isExpanded = false;
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  String imgUrl = "";
  String FileText = 'test';
  bool check = false;

  Future uploadFileToFirebase() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      try {
        PlatformFile f = result.files.first;
        print(f.name);
        print(f.extension);
        String fileName = result.files.first.name;
        webImage = result.files.single.bytes!;
// above works
        final storageReference =
            FirebaseStorage.instance.ref().child('maps/$fileName');

        UploadTask uploadTask = storageReference.putData(webImage);
        await uploadTask.whenComplete(() => null);
        print("uploaded");
        storageReference.getDownloadURL().then((fileURL) {
          setState(() {
            check = true;

            FileText = fileURL;
            if (_formKey.currentState!.validate()) {
              FirebaseFirestore.instance.collection("maps").doc(building).set({
                "building": building,
                "height": height,
                "width": width,
                "floor plan": FileText,
              });
            }
          });
        });
        print(
            "--------------------------------------- Url $FileText -------------------------------------");
      } catch (e) {
        print(e);
      }
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("Something Went wrong"),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: BackgroundAddMapp(
                  child: Expanded(
                child: Row(
                  children: [
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => addMaps()));
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
                        selectedIconTheme: IconThemeData(
                            color: Color.fromARGB(255, 25, 54, 152)),
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
                    Form(
                      key: _formKey,
                      child: Expanded(
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
                                  "اضافة خريطة جديدة",
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
                            Container(
                              margin: EdgeInsets.only(left: size.width * 0.65),
                              child: Column(
                                children: [
                                  Container(
                                    height: 200,
                                    width: 80,
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                  Center(
                                    child: Container(
                                      width: size.width * 0.25,
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onChanged: (value) {
                                          building = value;
                                        },
                                        controller: buildingName,
                                        decoration: const InputDecoration(
                                            labelText: "اسم المبنى",
                                            hintText: "كلية الحقوق",
                                            hintStyle: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 202, 198, 198)),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                              fontSize: 25,
                                              color: Color.fromARGB(
                                                  255, 45, 66, 142),
                                            )),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'الرجاء ادخال اسم المبنى';
                                          }
                                          if (value.length >= 3 &&
                                              value.length <= 20) {
                                            return 'الرجاء ادخال اسم المبنى';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: size.width * 0.25,
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onChanged: (value) {
                                          height = value;
                                        },
                                        controller: buildingHeight,
                                        decoration: const InputDecoration(
                                            labelText: " طول المبنى ",
                                            hintText: "١٠٠",
                                            hintStyle: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 202, 198, 198)),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                              fontSize: 25,
                                              color: Color.fromARGB(
                                                  255, 45, 66, 142),
                                            )),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'الرجاء ادخال الطول ';
                                          } else if (!RegExp(r'[0-9]')
                                                  .hasMatch(value) &&
                                              !RegExp(r'[٠-٩]')
                                                  .hasMatch(value)) {
                                            return 'الرجاء ادخال رقم صحيح ';
                                          }

                                          //return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      width: size.width * 0.25,
                                      child: TextFormField(
                                        autovalidateMode:
                                            AutovalidateMode.onUserInteraction,
                                        onChanged: (value) {
                                          width = value;
                                        },
                                        controller: buildingWidth,
                                        decoration: const InputDecoration(
                                            labelText: " عرض المبنى ",
                                            hintText: "٢٠٠",
                                            hintStyle: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 202, 198, 198)),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            labelStyle: TextStyle(
                                              fontSize: 25,
                                              color: Color.fromARGB(
                                                  255, 45, 66, 142),
                                            )),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'الرجاء ادخال العرض ';
                                          } else if (!RegExp(r'[0-9]')
                                                  .hasMatch(value) &&
                                              !RegExp(r'[٠-٩]')
                                                  .hasMatch(value)) {
                                            return 'الرجاء ادخال رقم صحيح ';
                                          }
                                          //return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Color.fromARGB(255, 83, 83, 83),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    onPressed: () => uploadFileToFirebase(),
                                    child: Text(
                                      "اضغط هنا لرفع صورة خريطة المبنى من نوع PNG او JPEG                       ",
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 45, 66, 142),
                                          fontSize: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 40),
                            Container(
                              margin: EdgeInsets.only(left: size.width * 0.65),
                              height: 30,
                              width: 150,
                              child: TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 45, 66, 142),
                                  ),
                                  onPressed: () async {
                                    //uploadFile;
                                    if (_formKey.currentState!.validate()) {
                                      FocusScope.of(context).unfocus();
                                      if (building == "" ||
                                          width == "" ||
                                          height == "")
                                        CoolAlert.show(
                                          context: context,
                                          width: size.width * 0.2,
                                          confirmBtnColor:
                                              Color.fromARGB(255, 45, 66, 142),
                                          //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                                          type: CoolAlertType.warning,
                                          backgroundColor:
                                              Color.fromARGB(255, 45, 66, 142),
                                          text:
                                              "الرجاء ادخال كامل معلومات الخريطة",
                                          confirmBtnText: 'اغلاق',
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      else if (check == false) {
                                        CoolAlert.show(
                                          context: context,
                                          width: size.width * 0.2,
                                          confirmBtnColor:
                                              Color.fromARGB(255, 45, 66, 142),
                                          //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                                          type: CoolAlertType.warning,
                                          backgroundColor:
                                              Color.fromARGB(255, 45, 66, 142),
                                          text: "الرجاء ارفاق صورة الخريطة",
                                          confirmBtnText: 'اغلاق',
                                          onConfirmBtnTap: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      } else {
                                        // print(imageUri.toString());
                                        buildingName.clear();
                                        buildingHeight.clear();
                                        buildingWidth.clear();

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => addPlaces(
                                                    mapName: building)));
                                      }
                                    }
                                  },
                                  child: Text(
                                    "التالي",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 20),
                                  )),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              )));
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
