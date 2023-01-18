import 'package:flutter/material.dart';

class BackgroundAddMapp extends StatelessWidget {
  final Widget child;

  const BackgroundAddMapp({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height,
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: size.width * 0.49, top: 112),
            child: Positioned(
              child: Image.asset("assets/images/back.png",
                  height: size.height, width: size.width),
            ),
          ),
          child
        ],
      ),
    );
  }
}
