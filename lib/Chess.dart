import 'package:flutter/material.dart';
import 'Constant.dart';

var _paint = Paint()
  ..color = Colors.black
  ..strokeCap = StrokeCap.round
  ..isAntiAlias = true
  ..strokeWidth = 2.0
  ..style = PaintingStyle.stroke;

class Chess extends CustomPainter {
  late int row;
  late int col;
  late String name;
  late bool isRed = isRedChess();
  late bool dead = false;
  late bool attacked = false;

  Chess(this.row, this.col, this.name);
  bool isRedChess(){
    return name.toUpperCase() == name.substring(0, 1);
  }
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(col * gridSize + boardPadding,
            row * gridSize + boardPadding + coordinateHeight),
        chessRadius,
        _paint
          ..style = isRed ? PaintingStyle.stroke : PaintingStyle.fill
          ..color = dead
              ? Colors.grey
              : attacked
                  ? Colors.amberAccent
                  : Colors.black);
    if (isRed) {
      canvas.drawCircle(
          Offset(col * gridSize + boardPadding,
              row * gridSize + boardPadding + coordinateHeight),
          chessRadius,
          _paint
            ..style = PaintingStyle.fill
            ..color = dead
                ? Colors.grey
                : attacked
                    ? Colors.amberAccent
                    : Colors.white);
    }
    TextPainter(
        text: TextSpan(
            text: chessNames[name],
            style: TextStyle(
                fontSize: 40.0,
                color: isRed ? Colors.black : Colors.white,
                fontFamily: fontLi)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: 40.0, minWidth: 40.0)
      ..paint(
          canvas,
          Offset(col * gridSize + boardPadding - boardMargin,
              row * gridSize + boardPadding));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
