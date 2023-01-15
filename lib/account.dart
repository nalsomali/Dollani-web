// import 'dart:convert';
// import 'dart:io';
// import 'dart:typed_data';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firabase_storage;

// import 'package:http/http.dart' as http;

// class Account extends StatefulWidget {
//   @override
//   State<Account> createState() => _AccountState();
// }

// class _AccountState extends State<Account> {
//   String defaultImageUrl =
//       'https://cdn.pixabay.com/photo/2016/03/23/15/00/ice-cream-1274894_1280.jpg';
//   String selctFile = '';
//   Uint8List selectedImageInBytes = Uint8List(8);
//   List<Uint8List> pickedImagesInBytes = [];
//   List<String> imageUrls = [];
//   int imageCounts = 0;
//   TextEditingController _itemNameController = TextEditingController();
//   TextEditingController _itemPriceController = TextEditingController();
//   TextEditingController _deviceTokenController = TextEditingController();
//   bool isItemSaved = false;

//   @override
//   void initState() {
//     //deleteVegetable();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _itemNameController.dispose();
//     _itemPriceController.dispose();
//     super.dispose();
//   }

//   //This modal shows image selection either from gallery or camera
//   // void _showPicker(BuildContext context) {
//   //   showModalBottomSheet(
//   //     //backgroundColor: Colors.transparent,
//   //     context: context,
//   //     builder: (BuildContext bc) {
//   //       return SafeArea(
//   //         child: Container(
//   //           height: MediaQuery.of(context).size.height * 0.15,
//   //           decoration: const BoxDecoration(
//   //             borderRadius: BorderRadius.only(
//   //               topLeft: Radius.circular(25),
//   //               topRight: Radius.circular(25),
//   //             ),
//   //           ),
//   //           child: Wrap(
//   //             children: <Widget>[
//   //               SizedBox(
//   //                 height: 10,
//   //               ),
//   //               ListTile(
//   //                   leading: const Icon(
//   //                     Icons.photo_library,
//   //                   ),
//   //                   title: const Text(
//   //                     'Gallery',
//   //                     style: TextStyle(),
//   //                   ),
//   //                   onTap: () {
//   //                     _selectFile(true);
//   //                     Navigator.of(context).pop();
//   //                   }),
//   //               ListTile(
//   //                 leading: const Icon(
//   //                   Icons.photo_camera,
//   //                 ),
//   //                 title: const Text(
//   //                   'Camera',
//   //                   style: TextStyle(),
//   //                 ),
//   //                 onTap: () {
//   //                   _selectFile(false);
//   //                   Navigator.of(context).pop();
//   //                 },
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }

//   _selectFile(bool imageFrom) async {
//     FilePickerResult? fileResult = await FilePicker.platform.pickFiles();
//     if (fileResult != null) {
//       setState(() {
//         selctFile = fileResult.files.first.name;
//         selectedImageInBytes = fileResult.files.first.bytes!;
//       });
//     }
//     print(selctFile);
   
//   }

//   Future<String> _uploadFile() async {
//     String imageUrl = '';
//     try {
//       firabase_storage.UploadTask uploadTask;

//       firabase_storage.Reference ref = firabase_storage.FirebaseStorage.
//       instance
//           .ref()
//           .child('MapImages')
//           .child('/' + selctFile);

//       final metadata =
//           firabase_storage.SettableMetadata(contentType: 'image/jpeg');

   
//       uploadTask = ref.putData(selectedImageInBytes, metadata);

//       await uploadTask.whenComplete(() => null);
//       imageUrl = await ref.getDownloadURL();
//       print("upload" + imageUrl);
//     } catch (e) {
//       print(e);
//     }
//     return imageUrl;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Vegetable Seller',
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.02,
//               ),
//               Container(
//                   height: MediaQuery.of(context).size.height * 0.35,
//                   width: MediaQuery.of(context).size.width * 0.3,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(
//                       15,
//                     ),
//                   ),
//                   child: selctFile.isEmpty
//                       ? Image.network(
//                           defaultImageUrl,
//                           fit: BoxFit.cover,
//                         )
//                       :
//                       // Image.asset('assets/create_menu_default.png')
//                       // : CarouselSlider(
//                       //     options: CarouselOptions(height: 400.0),
//                       //     items: pickedImagesInBytes.map((i) {
//                       //       return Builder(
//                       //         builder: (BuildContext context) {
//                       //           return Container(
//                       //             width: MediaQuery.of(context).size.width,
//                       //             margin: EdgeInsets.symmetric(horizontal: 5.0),
//                       //             decoration:
//                       //                 BoxDecoration(color: Colors.amber),
//                       //             child: Image.memory(i),
//                       //           );
//                       //         },
//                       //       );
//                       //     }).toList(),
//                       //   )
//                       Image.memory(selectedImageInBytes)

//                   // Image.file(
//                   //     File(file.path),
//                   //     fit: BoxFit.fill,
//                   //   ),
//                   ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.02,
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.05,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     //_showPicker(context);
//                     _selectFile(true);
//                   },
//                   icon: const Icon(
//                     Icons.camera,
//                   ),
//                   label: const Text(
//                     'Pick Image',
//                     style: TextStyle(),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.02,
//               ),
//               Container(
//                 child: CircularProgressIndicator(
//                   color: Colors.green,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: Container(
//         width: MediaQuery.of(context).size.width * 0.08,
//         margin: EdgeInsets.only(
//           bottom: MediaQuery.of(context).size.height * 0.02,
//         ),
//         decoration: BoxDecoration(
//           color: Colors.green,
//           borderRadius: BorderRadius.circular(
//             25,
//           ),
//           // border: Border.all(
//           //   width: 1,
//           //   //color: Colors.black,
//           // ),
//         ),
//         child: TextButton(
//           onPressed: () {
//             _uploadFile();
//           },
//           child: Text(
//             'Save',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
