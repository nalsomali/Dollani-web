import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web/login.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:web/loading_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class addMap extends StatefulWidget {
  const addMap({Key? key}) : super(key: key);

  @override
  State<addMap> createState() => _addMapState();
}

class _addMapState extends State<addMap> {
  //setting the expansion function for the navigation rail
  bool isExpanded = false;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);
  double x = 0.0;
  double y = 0.0;
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

          MouseRegion(
            onHover: _updateLocation,
            child: Column(
              children: [
                Container(
                    height: 500,
                    width: 400,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: _pickedImage == null
                        ? dottedBorder(color: Colors.black)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.memory(webImage, fit: BoxFit.fill)
                                : Image.file(_pickedImage!, fit: BoxFit.fill),
                          )),
                Text(
                  'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
                )
              ],
            ),
          ),
        ],
      ),
      //let's add the floating action button
    );
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('لم تختر صورة');
      }
    } else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('لم تختر صورة');
      }
    } else {
      print('حدث خطأ');
    }
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
                      _pickImage();
                    }),
                    child: Text(
                      "اضغط هنا لإضافة صورة الخريطة",
                    ))
              ],
            ),
          )),
    );
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }
}
