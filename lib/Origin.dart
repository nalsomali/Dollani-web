import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _tapPosition = Offset.zero),
        child: Icon(Icons.clear),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
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
