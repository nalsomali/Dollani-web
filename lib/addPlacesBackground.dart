import 'package:flutter/material.dart';

class addPlacesBackground extends StatelessWidget {
  final Widget child;

  const addPlacesBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: Image(
              image: AssetImage('assets/images/background_Add.jpg'),
              fit: BoxFit.fill,
            ),
          ),
          child
        ],
      ),
    );
  }
}
