import 'package:flutter/material.dart';

const double chessRadius = 25;
const double boardWidth = 540;
const double boardHeight = 650;
const double gridSize = 60;
const double boardPadding = 30;
const double boardMargin = boardPadding * 2 / 3;
const double coordinateHeight = 25;
const double boxWidth = 200;
const double boxHeight = 9 * gridSize;
const double lineHeight = 20;
const String coordinate = "九八七六五四三二一";
const String fontLi = "simli";
const String gameTitle = "中國象棋譜";
const String standardFen =
    "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR";
const Map chessNames = {
  "r": "車",
  "R": "車",
  "n": "馬",
  "N": "馬",
  "b": "象",
  "B": "相",
  "a": "士",
  "A": "仕",
  "k": "將",
  "K": "帥",
  "p": "卒",
  "P": "兵",
  "c": "砲",
  "C": "炮"
};
const List<List<int>> decorate = [
  [1, 2],
  [7, 2],
  [0, 3],
  [2, 3],
  [4, 3],
  [6, 3],
  [8, 3],
  [1, 7],
  [7, 7],
  [0, 6],
  [2, 6],
  [4, 6],
  [6, 6],
  [8, 6]
];
