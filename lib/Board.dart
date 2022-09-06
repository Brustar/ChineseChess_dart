import 'dart:math';
import 'package:flutter/material.dart';
import 'package:chinese_chess/Constant.dart';

import 'Chess.dart';
import 'Game.dart';

Paint _paint = Paint()
  ..color = Colors.black
  ..strokeCap = StrokeCap.round
  ..isAntiAlias = true
  ..strokeWidth = 4.0
  ..style = PaintingStyle.stroke;

extension CanvasExt on Canvas {
  ///绘制虚线
  ///[p1] 起点
  ///[p2] 终点
  ///[dashWidth] 实线宽度
  ///[spaceWidth] 空隙宽度
  void drawDashLine(
    Offset p1,
    Offset p2,
    double dashWidth,
    double spaceWidth,
    Paint paint,
  ) {
    assert(dashWidth > 0);
    assert(spaceWidth > 0);

    double radians;

    if (p1.dx == p2.dx) {
      radians = (p1.dy < p2.dy) ? pi / 2 : pi / -2;
    } else {
      radians = atan2(p2.dy - p1.dy, p2.dx - p1.dx);
    }

    save();
    translate(p1.dx, p1.dy);
    rotate(radians);

    var matrix = Matrix4.identity();
    matrix.translate(p1.dx, p1.dy);
    matrix.rotateZ(radians);
    matrix.invert();

    var endPoint = MatrixUtils.transformPoint(matrix, p2);

    double tmp = 0;
    double length = endPoint.dx;
    double delta;

    while (tmp < length) {
      delta = (tmp + dashWidth < length) ? dashWidth : length - tmp;
      drawLine(Offset(tmp, 0), Offset(tmp + delta, 0), paint);
      if (tmp + delta >= length) {
        break;
      }

      tmp = (tmp + dashWidth + spaceWidth < length)
          ? (tmp + dashWidth + spaceWidth)
          : (length);
    }
    restore();
  }
}

class Board extends CustomPainter {
  late Game game;

  Board(this.game);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        const Rect.fromLTWH(boardMargin, boardMargin + coordinateHeight,
            8 * gridSize + boardMargin, 9 * gridSize + boardMargin),
        _paint..strokeWidth = 3.0);
    canvas.drawShadow(
        Path()
          ..moveTo(boardMargin - 1, boardMargin + coordinateHeight - 3)
          ..lineTo(2 * boardMargin + 8 * gridSize + 4,
              boardMargin + coordinateHeight - 3)
          ..lineTo(2 * boardMargin + 8 * gridSize + 4,
              boardMargin + 2 * coordinateHeight + 9 * gridSize - 2)
          ..lineTo(boardMargin - 1,
              boardMargin + 2 * coordinateHeight + 9 * gridSize - 2)
          ..close(),
        Colors.black,
        3,
        false);
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 9; j++) {
        if (j != 4) {
          double x = boardPadding + i * gridSize;
          double y = boardPadding + j * gridSize + coordinateHeight;
          canvas.drawRect(
              Rect.fromLTWH(
                  boardPadding + i * gridSize,
                  boardPadding + j * gridSize + coordinateHeight,
                  gridSize,
                  gridSize),
              _paint
                ..strokeWidth = 2.0
                ..color = Colors.black);
        }
      }
    }
    canvas.drawLine(
        const Offset(
            boardPadding, 4 * gridSize + coordinateHeight + boardPadding),
        const Offset(
            boardPadding, 5 * gridSize + coordinateHeight + boardPadding),
        _paint);
    canvas.drawLine(
        const Offset(boardPadding + 8 * gridSize,
            4 * gridSize + coordinateHeight + boardPadding),
        const Offset(boardPadding + 8 * gridSize,
            5 * gridSize + coordinateHeight + boardPadding),
        _paint);
    drawDiagonal(canvas);
    drawDecorate(canvas);
    drawCoordinate(canvas);
    drawChesses(canvas, size);
    drawTracks(canvas);
    drawPossibleStep(canvas);
  }

  void drawChesses(Canvas canvas, Size size) {
    for (Chess chess in game.map) {
      chess.paint(canvas, size);
    }
  }

  void drawDiagonal(Canvas canvas) {
    canvas.drawDashLine(
        const Offset(
            boardPadding + 3 * gridSize, boardPadding + coordinateHeight),
        const Offset(boardPadding + 5 * gridSize,
            boardPadding + 2 * gridSize + coordinateHeight),
        5,
        5,
        _paint);
    canvas.drawDashLine(
        const Offset(
            boardPadding + 5 * gridSize, boardPadding + coordinateHeight),
        const Offset(boardPadding + 3 * gridSize,
            boardPadding + 2 * gridSize + coordinateHeight),
        5,
        5,
        _paint);
    canvas.drawDashLine(
        const Offset(boardPadding + 3 * gridSize,
            boardPadding + 7 * gridSize + coordinateHeight),
        const Offset(boardPadding + 5 * gridSize,
            boardPadding + 9 * gridSize + coordinateHeight),
        5,
        5,
        _paint);
    canvas.drawDashLine(
        const Offset(boardPadding + 5 * gridSize,
            boardPadding + 7 * gridSize + coordinateHeight),
        const Offset(boardPadding + 3 * gridSize,
            boardPadding + 9 * gridSize + coordinateHeight),
        5,
        5,
        _paint);
  }

  void drawDecorate(Canvas canvas) {
    for (int i = 0; i < decorate.length; i++) {
      int margin = 5;
      int x = decorate[i][0];
      int y = decorate[i][1];
      if (x != 0) {
        //竖
        canvas.drawLine(
            Offset(x * gridSize - margin + boardPadding,
                y * gridSize - 3 * margin + boardPadding + coordinateHeight),
            Offset(x * gridSize - margin + boardPadding,
                y * gridSize - margin + boardPadding + coordinateHeight),
            _paint);
        //横
        canvas.drawLine(
            Offset(x * gridSize - margin + boardPadding,
                y * gridSize - margin + boardPadding + coordinateHeight),
            Offset(x * gridSize - 3 * margin + boardPadding,
                y * gridSize - margin + boardPadding + coordinateHeight),
            _paint);
      }
      if (x != 0) {
        canvas.drawLine(
            Offset(x * gridSize + boardPadding - margin,
                y * gridSize + boardPadding + 3 * margin + coordinateHeight),
            Offset(x * gridSize + boardPadding - margin,
                y * gridSize + boardPadding + margin + coordinateHeight),
            _paint);
        canvas.drawLine(
            Offset(x * gridSize + boardPadding - margin,
                y * gridSize + boardPadding + margin + coordinateHeight),
            Offset(x * gridSize + boardPadding - 3 * margin,
                y * gridSize + boardPadding + margin + coordinateHeight),
            _paint);
      }
      if (x != 8) {
        canvas.drawLine(
            Offset(x * gridSize + margin + boardPadding,
                y * gridSize + boardPadding - 3 * margin + coordinateHeight),
            Offset(x * gridSize + margin + boardPadding,
                y * gridSize - margin + boardPadding + coordinateHeight),
            _paint);
        canvas.drawLine(
            Offset(x * gridSize + margin + boardPadding,
                y * gridSize + boardPadding - margin + coordinateHeight),
            Offset(x * gridSize + 3 * margin + boardPadding,
                y * gridSize - margin + boardPadding + coordinateHeight),
            _paint);
      }
      if (x != 8) {
        canvas.drawLine(
            Offset(
                x * gridSize + margin + boardPadding,
                y * gridSize +
                    boardPadding -
                    3 * margin +
                    coordinateHeight +
                    boardPadding),
            Offset(x * gridSize + margin + boardPadding,
                y * gridSize + margin + boardPadding + coordinateHeight),
            _paint);
        canvas.drawLine(
            Offset(x * gridSize + margin + boardPadding,
                y * gridSize + margin + boardPadding + coordinateHeight),
            Offset(x * gridSize + 3 * margin + boardPadding,
                y * gridSize + margin + boardPadding + coordinateHeight),
            _paint);
      }
    }
    TextPainter(
        text: const TextSpan(
            text: "楚 河",
            style: TextStyle(
                fontSize: chessRadius * 2 - 10,
                color: Colors.black,
                fontFamily: fontLi)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: 6 * chessRadius, minWidth: chessRadius * 2)
      ..paint(canvas, const Offset(gridSize, 5 * gridSize));
    TextPainter(
        text: const TextSpan(
            text: "漢 界",
            style: TextStyle(
                fontSize: chessRadius * 2 - 10,
                color: Colors.black,
                fontFamily: fontLi)),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center)
      ..layout(maxWidth: 6 * chessRadius, minWidth: chessRadius * 2)
      ..paint(canvas, const Offset(6 * gridSize, 5 * gridSize));
  }

  void drawCoordinate(Canvas canvas) {
    for (int i = 0; i < 9; i++) {
      TextPainter(
          text: TextSpan(
              text: (i + 1).toString(),
              style: const TextStyle(fontSize: 18.0, color: Colors.grey)),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 20.0, minWidth: 20.0)
        ..paint(canvas, Offset(i * gridSize + boardMargin, 0));
      TextPainter(
          text: TextSpan(
              text: coordinate[i],
              style: const TextStyle(
                  fontSize: 14.0, color: Colors.grey, fontFamily: "Roboto")),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center)
        ..layout(maxWidth: 20.0, minWidth: 20.0)
        ..paint(
            canvas,
            Offset(
                i * gridSize + boardMargin, 9 * gridSize + 3 * boardPadding));
    }
  }

  void drawPossibleStep(Canvas canvas) {
    for (Point p in game.possibleMove) {
      canvas.drawCircle(
          Offset(p.col * gridSize + boardPadding,
              p.row * gridSize + boardPadding + coordinateHeight),
          chessRadius / 2,
          _paint
            ..style = PaintingStyle.fill
            ..color = Colors.white);
      canvas.drawCircle(
          Offset(p.col * gridSize + boardPadding,
              p.row * gridSize + boardPadding + coordinateHeight),
          chessRadius / 2,
          _paint
            ..style = PaintingStyle.stroke
            ..color = Colors.black);
    }
  }

  void drawTracks(Canvas canvas) {
    for (Point p in game.tracks.pair) {
      double x = p.col * gridSize;
      double y = p.row * gridSize + coordinateHeight;
      Path path = Path();
      path
        ..moveTo(x, y + 10)
        ..lineTo(x, y)
        ..relativeLineTo(10, 0);
      canvas.drawPath(path, _paint);

      x += gridSize;
      path
        ..moveTo(x - 10, y)
        ..lineTo(x, y)
        ..relativeLineTo(0, 10);
      canvas.drawPath(path, _paint);

      y += gridSize;
      path
        ..moveTo(x, y - 10)
        ..lineTo(x, y)
        ..relativeLineTo(-10, 0);
      canvas.drawPath(path, _paint);

      x -= gridSize;
      path
        ..moveTo(x, y - 10)
        ..lineTo(x, y)
        ..relativeLineTo(10, 0);
      canvas.drawPath(path, _paint);
    }
  }

  @override
  bool shouldRepaint(covariant Board oldDelegate) {
    return true;
  }
}
