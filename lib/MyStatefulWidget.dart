import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Flutter Listener Class Sample")),
        body: const Center(
          child: MyStatefulWidget(),
        ),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);
  @override
  State createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State {
  int _down = 0;
  int _up = 0;
  double x = 0.0;
  double y = 0.0;
  void _incrementDown(PointerEvent details) {
    _updateLocation(details);
    setState(() {
      _down++;
    });
  }

  void _incrementUp(PointerEvent details) {
    _updateLocation(details);
    setState(() {
      _up++;
    });
  }

  void _updateLocation(PointerEvent details) {
    setState(() {
      x = details.position.dx;
      y = details.position.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(const Size(400.0, 300.0)),
      child: Listener(
        // onPointerDown: _incrementDown,
        onPointerMove: _updateLocation,
        // onPointerUp: _incrementUp,
        child: Container(
          color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                  'You have pressed or released in this area this many times:'),
              Text(
                '$_down presses\n$_up releases',
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                'The cursor is here: (${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
