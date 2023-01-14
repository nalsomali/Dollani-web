import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web/login.dart';
import 'package:web/addMap.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  String buildingName = "";
  String floorPlan = "";

  void initState() {
    getMap();
    super.initState();
  }

  Future getMap() async {
    setState(() {
      buildingName = "";
      floorPlan = "";
    });
    await for (var snapshot
        in FirebaseFirestore.instance.collection('maps').snapshots())
      for (var map in snapshot.docs) {
        setState(() {
          buildingName = map['building'].toString();
        });
      }
  }

  //setting the expansion function for the navigation rail
  bool isExpanded = false;
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
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //let's add the navigation menu for this project
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
                          "دُلني هو بصيرة المكفوف التي لا تخيب ! ",
                          style: TextStyle(
                              fontSize: 20,
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
                    //Now let's start with the dashboard main rapports

                    //Now let's set the article section
                    SizedBox(
                      height: 30.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "  الخرائط",
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
                            decoration: InputDecoration(
                              hintText: "البحث بإسم المبنى",
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromARGB(66, 0, 0, 0),
                                ),
                              ),
                            ),
                          ),
                        )
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
                            "هنا قائمة بجمبع الخرائط المضافة",
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
                                      builder: (context) => addMap()));
                            },
                            child: Text(
                              "اضافة خريطة جديدة",
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
                              DataColumn(label: Text("اسم المبنى")),
                              DataColumn(label: Text("تعديل")),
                              DataColumn(label: Text("حذف")),
                            ],
                            rows: [
                              DataRow(cells: [
                                DataCell(Text(buildingName)),
                                DataCell(Icon(
                                  Icons.edit,
                                  color: Color.fromARGB(255, 74, 93, 188),
                                )),
                                DataCell(Icon(
                                  Icons.delete,
                                  color: Color.fromARGB(255, 74, 93, 188),
                                ))
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
