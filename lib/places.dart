import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web/editPlace.dart';
import 'package:web/maps.dart';

import 'addMap.dart';
import 'addNewPlace.dart';
import 'login.dart';

class places extends StatefulWidget {
  String mapName;

  places({
    required this.mapName,
  });

  @override
  State<places> createState() => placesScreenState(mapName);
}

class placesScreenState extends State<places> {
  String mapName;
  placesScreenState(this.mapName);

  @override
  void initState() {
    getPlaces();

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

  TextEditingController? _searchEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool isExpanded = false;
    Size size = MediaQuery.of(context).size;

    Future getSearch(String search) async {
      if (search == "") return;
      if (placeName.where((element) => element == (search)).isEmpty) {
        CoolAlert.show(
          context: context,
          title: "نعتذر",
          width: size.width * 0.2,
          confirmBtnColor: Color.fromARGB(255, 45, 66, 142),
          //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
          type: CoolAlertType.error,
          backgroundColor: Color.fromARGB(255, 45, 66, 142),
          text: "لا يوجد موقع بهذا الاسم",
          confirmBtnText: 'حاول مره اخرى',
          onConfirmBtnTap: () {
            Navigator.of(context).pop();
          },
        );
        return;
      }
      //clear first
      setState(() {
        placeName = [];
        category = [];
      });

      await for (var snapshot in FirebaseFirestore.instance
          .collection('places')
          .where('name', isEqualTo: search)
          .snapshots())
        for (var place in snapshot.docs) {
          setState(() {
            placeName.add(place['name']);
            category.add(place['category']);
          });
        }
    }

    return Scaffold(
        backgroundColor: Colors.white,
        body: Row(children: [
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
              selectedIndex: 0),
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
                      " خريطة $mapName",
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
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          "  الأماكن",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28.0,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 300.0,
                      child: TextField(
                        controller: _searchEditingController,
                        decoration: InputDecoration(
                          hintText: "البحث بإسم الموقع",
                          icon: IconButton(
                            icon: Icon(Icons.cancel_presentation),
                            onPressed: () {
                              setState(() {
                                getPlaces();
                                _searchEditingController?.clear();
                              });
                            },
                          ),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () {
                              setState(() {
                                getSearch(_searchEditingController!.text);
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(66, 0, 0, 0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),

                //let's set the filter section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.arrow_downward,
                        color: Color.fromARGB(255, 45, 66, 142),
                      ),
                      label: Text(
                        "هنا قائمة بجميع المواقع المضافة بالخريطة",
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 66, 142),
                        ),
                      ),
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 45, 66, 142),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => addNewPlace(
                                        mapName: mapName,
                                      )));
                        },
                        child: Text(
                          "اضافة موقع جديد",
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                //Now let's add the Table

                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => Color.fromARGB(255, 227, 227, 227)),
                        columns: [
                          DataColumn(label: Text("اسم الموقع")),
                          DataColumn(label: Text("تصنيف الموقع")),
                          DataColumn(label: Text("تعديل")),
                          DataColumn(label: Text("حذف")),
                        ],
                        rows: [
                          for (var i = 0; i < placeName.length; i++)
                            DataRow(cells: [
                              DataCell(Text(placeName[i])),
                              DataCell(Text(category[i])),
                              DataCell(IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => editPlaces(
                                                  mapName: placeName[i],
                                                  Map: mapName,
                                                )));
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Color.fromARGB(255, 74, 93, 188),
                                  ))),
                              DataCell(TextButton(
                                  onPressed: () {
                                    CoolAlert.show(
                                      context: context,
                                      title: " حذف الموقع",
                                      width: size.width * 0.2,
                                      confirmBtnColor:
                                          Color.fromARGB(181, 172, 22, 12),
                                      showCancelBtn: false,
                                      //cancelBtnColor: Color.fromARGB(144, 64, 6, 87),
                                      type: CoolAlertType.confirm,
                                      backgroundColor:
                                          Color.fromARGB(255, 45, 66, 142),
                                      text: "هل تريد حذف الموقع",
                                      confirmBtnText: 'حذف ',
                                      cancelBtnText: "إلغاء",
                                      onCancelBtnTap: () {
                                        Navigator.pop(context);
                                      },
                                      onConfirmBtnTap: () async {
                                        FirebaseFirestore.instance
                                            .collection('places')
                                            .doc(category[i] +
                                                "-" +
                                                placeName[i])
                                            .delete();

                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => places(
                                                      mapName: mapName,
                                                    )));
                                      },
                                    );
                                  },
                                  child: Icon(
                                    Icons.delete,
                                    color: Color.fromARGB(255, 74, 93, 188),
                                  )))
                            ]),
                        ]),
                    //Now let's set the pagination
                    SizedBox(
                      height: 40.0,
                    ),
                  ],
                ),
              ],
            ),
          )
        ]));
  }
  // Title list
}
