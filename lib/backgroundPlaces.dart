import 'package:flutter/material.dart';

class BackgroundAddPlaces extends StatelessWidget {
  final Widget child;

  const BackgroundAddPlaces({
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
          Positioned(
            child: Image.asset("assets/images/backgroundPlaces.png",
                width: size.width),
          ),
          child
        ],
      ),
    );
  }
}
