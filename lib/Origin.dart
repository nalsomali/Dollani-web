import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:web/maps.dart';

import 'addMapsScreen.dart';
import 'login.dart';

class ImagePage extends StatefulWidget {
  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  Offset _tapPosition = Offset.zero;

  void _handleTap(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() => _tapPosition = Offset.zero),
          child: Icon(Icons.clear),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: Center(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                selectedIndex: 0),
            Column(
              children: [
                Expanded(
                  child: CustomPaint(
                    painter: ImagePainter(
                        _tapPosition, "assets/images/background_maps.png"),
                    child: GestureDetector(
                      onTapDown: _handleTap,
                      onTapUp: (TapUpDetails details) =>
                          _tapPosition = details.localPosition,
                      child: Image.asset(
                        "assets/images/background_maps.png",
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 50,
                  child: _tapPosition == Offset.zero
                      ? Text('No point selected')
                      : Text(
                          'x: ${_tapPosition.dx.round()}, y: ${_tapPosition.dy.round()}'),
                  padding: EdgeInsets.all(16),
                ),
              ],
            ),
            Container()
          ]),
        ));
  }
}

class ImagePainter extends CustomPainter {
  final Offset tapPosition;
  final String img;

  ImagePainter(this.tapPosition, this.img);

  @override
  void paint(Canvas canvas, Size size) {
    if (tapPosition != null && tapPosition != Offset.zero) {
      canvas.drawCircle(tapPosition, 8, Paint()..color = Colors.red);
    }
  }

  @override
  bool shouldRepaint(ImagePainter oldDelegate) =>
      tapPosition != oldDelegate.tapPosition;
}
