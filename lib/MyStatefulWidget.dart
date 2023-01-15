import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_dart/storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

late String pickedfilename;
Uint8List? pickedfile;
TextEditingController sampleController = TextEditingController();
Future selectFile() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result == null) return;

  pickedfile = result.files.first.bytes;
  pickedfilename = result.files.first.name;
  // uploadFile();
}

@override
Future uploadFile() async {
  UploadTask task = FirebaseStorage.instance
      .ref()
      .child("files/$pickedfilename")
      .putData(pickedfile!);

  final snapshot = await task.whenComplete(() {});
  final urlDownload = await snapshot.ref.getDownloadURL();
  sampleController.text = '$urlDownload';

  print('downlaod :$urlDownload');
}

Future uplokadFile() async {
  if (true) {
    if (Type == null) {
      print(Type);
    } else {
      var task = FirebaseStorage.instance
          .ref()
          .child("files/$pickedfilename")
          .putData(pickedfile!);

      final snapshot = await task.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      sampleController.text = '$urlDownload';
      // isuploaded = true;
      print('downlaod :$urlDownload');
    }
  } else {
    print("no error");
  }
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
        constraints: BoxConstraints.tight(const Size(300.0, 200.0)),
        child: Column(
          children: [
            Center(
              child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  onPressed: () async {
                    selectFile();
                  },
                  child: Text(
                    "التالي",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  )),
            ),
            Center(
              child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 45, 66, 142),
                  ),
                  onPressed: () async {
                    uplokadFile();
                  },
                  child: Text(
                    "حفظ",
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  )),
            ),
          ],
        ));
  }
}
