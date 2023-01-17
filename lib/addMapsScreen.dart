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
  late String building;
  final TextEditingController buildingArea = TextEditingController();

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  String imgUrl = "";
  String FileText = 'test';

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
            FileText = fileURL;
            FirebaseFirestore.instance.collection("maps").doc(building).set({
              "building": building,
              "area": buildingArea.text,
              "floor plan": FileText,
            });
          });
        });
        print(
            "--------------------------------------- Url $FileText -------------------------------------");
      } catch (e) {
        print(e);
      }
    }
  }

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
              body: BackgroundAddMapp(
            child: Row(
              children: [
                NavigationRail(
                    extended: true,
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
                Row(
                  children: [
                    Container(
                      height: 100,
                      width: 80,
                    ),
                    Container(
                      child: Column(
                        children: [
                          Container(
                            height: 250,
                            width: 80,
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
                                    labelText: "اسم الخريطة",
                                    hintText: "كلية الحقوق",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 202, 198, 198)),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      fontSize: 25,
                                      color: Color.fromARGB(255, 45, 66, 142),
                                    )),
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
                                  buildingArea.text = value;
                                },
                                controller: buildingName,
                                decoration: const InputDecoration(
                                    labelText: "مساحة المبنى بالمتر المربع",
                                    hintText: "400",
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromARGB(255, 202, 198, 198)),
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      fontSize: 25,
                                      color: Color.fromARGB(255, 45, 66, 142),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
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
                                  "اضغط هنا لرفع صورة خريطة المبنى                       ",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 45, 66, 142),
                                      fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 45, 66, 142),
                              ),
                              onPressed: () async {
                                //uploadFile;
                                FocusScope.of(context).unfocus();

                                // print(imageUri.toString());
                                buildingName.clear();
                                buildingArea.clear();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            addPlaces(mapName: building)));
                              },
                              child: Text(
                                "التالي",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 20),
                              ))
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ));
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
