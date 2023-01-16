import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dart/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web/login.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web/loading_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
//import 'package:firebase_dart/firebase_dart.dart' as fb;

import 'package:web/addPlaces.dart';
import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;

import 'maps.dart';

class addMap extends StatefulWidget {
  const addMap({Key? key}) : super(key: key);

  @override
  State<addMap> createState() => _addMapState();
}

String selctFile = '';

bool isExpanded = false;
File? _pickedImage;
Uint8List webImage = Uint8List(8);
double x = 0.0;
double y = 0.0;
// Future<String> _uploadFile() async {
//   String imageUrl = '';
//   try {
//     firabase_storage.UploadTask uploadTask;

//     firabase_storage.Reference ref = firabase_storage.FirebaseStorage.instance
//         .ref()
//         .child('mapImages')
//         .child('/' + selctFile);

//     final metadata =
//         firabase_storage.SettableMetadata(contentType: 'image/jpeg');

//     //uploadTask = ref.putFile(File(file.path));
//     uploadTask = ref.putData(webImage, metadata);

//     await uploadTask.whenComplete(() => null);
//     imageUrl = await ref.getDownloadURL();
//   } catch (e) {
//     print(e);
//   }
//   return imageUrl;
// }

class _addMapState extends State<addMap> {
  String imageUrl = "نرا ماحفظ";
  Uint8List? selectedImageInByets;
  XFile? file;
  String selectimage = "";
  TextEditingController sampleController = TextEditingController();
  //setting the expansion function for the navigation rail
  late String building;
  final TextEditingController buildingName = TextEditingController();

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
                      MaterialPageRoute(builder: (context) => addMap()));
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

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                      height: 500,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: //selctFile.isEmpty
                          //     ? dottedBorder(color: Color.fromARGB(255, 0, 0, 0))
                          //     :

                          selctFile.isEmpty
                              ? dottedBorder(color: Colors.black)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: kIsWeb
                                      ? Image.memory(selectedImageInByets!,
                                          fit: BoxFit.fill)
                                      : Image.file(_pickedImage!,
                                          fit: BoxFit.fill),
                                )),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Container(
                  width: size.width * 0.25,
                  child: TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (value) {
                      building = value;
                    },
                    controller: buildingName,
                    decoration: const InputDecoration(
                        labelText: "اسم الخريطة",
                        hintText: "كلية الحقوق",
                        hintStyle: TextStyle(
                            color: Color.fromARGB(255, 202, 198, 198)),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(
                          fontSize: 19,
                          color: Color.fromARGB(255, 45, 66, 142),
                        )),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                  onPressed: uploadFile,
                  child: Text(
                    "رفع صورة الخريطة",
                    style: TextStyle(
                      color: Color.fromARGB(255, 141, 17, 17),
                    ),
                  )),
              TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  onPressed: () async {
                    uploadFile;
                    FocusScope.of(context).unfocus();

                    FirebaseFirestore.instance
                        .collection('maps')
                        .doc(building)
                        .set({
                      "building": building,
                      'floor plan': sampleController //imageUri.toString(),
                    });

                    // print(imageUri.toString());
                    buildingName.clear();
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
                    ),
                  ))
            ],
          ),
          //let's add the floating action button
        ]));
  }

  void uploadFile() async {
    var ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .putData(selectedImageInByets!);
    final snapshot = await ref.whenComplete(() {
      setState(() {
        // _isVisible = false;
        print("kkmmkkm");
      });
    });
    final urlDownload = await snapshot.ref.getDownloadURL();
    sampleController.text = '$urlDownload';

    // try {
    //   firabase_storage.UploadTask uploadTask;
    //   firabase_storage.Reference ref =
    //       firabase_storage.FirebaseStorage.instance.ref().child("mapImages");

    //   final metadata =
    //       firabase_storage.SettableMetadata(contentType: 'image/jpeg');
    //   uploadTask = ref.putData(selectedImageInByets!, metadata);

    //   imageUrl = "await ref.getDownloadURL();";
    //   print("uploa image   :" + imageUrl);
    // } catch (e) {
    //   print(e);
    // }
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
                      _selectFile();
                    }),
                    child: Text(
                      "اضغط هنا لإضافة صورة الخريطة",
                    ))
              ],
            ),
          )),
    );
  }

  void _selectFile() async {
    FilePickerResult? fileResult = await FilePicker.platform.pickFiles();
    if (fileResult != null) {
      setState(() {
        selctFile = fileResult.files.first.name;
        selectedImageInByets = fileResult.files.first.bytes;
      });
    }
    ;
    print(file!.name);
  }
}
