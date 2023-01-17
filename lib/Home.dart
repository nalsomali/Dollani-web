import 'dart:html';
import 'package:file_picker/file_picker.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

Uint8List webImage = Uint8List(8);

class _HomeState extends State<Home> {
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
            FirebaseFirestore.instance.collection("maps").add({
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
              body: Column(
            children: [
              imgUrl == null
                  ? Placeholder(
                      fallbackHeight: 200,
                      fallbackWidth: 400,
                    )
                  : Container(
                      height: 300,
                      width: 300,
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
              SizedBox(
                height: 50,
              ),
              TextButton(
                onPressed: () => uploadFileToFirebase(),
                child: Text("Upload"),
              ),
            ],
          ));
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
