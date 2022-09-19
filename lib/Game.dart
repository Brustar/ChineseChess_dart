import 'dart:math';
import 'package:chinese_chess/Constant.dart';
import 'Chess.dart';
import 'Pair.dart';

class Point {
  int row = -1;
  int col = -1;

  Point(this.row, this.col);
}

class Game {
  List<Chess> map = [];
  List<Point> possibleMove = [];
  List<String> staves = [];
  String stave = "";
  List<String> steps = [];
  Chess driveChess = Chess(-1, -1, "*");
  bool redGo = true;
  Pair tracks = Pair();

  void restart() {
    map.clear();
    tracks.clear();
    // staves.clear();
    // steps.clear();
    // redGo = true;
  }

  void drawFromFen(String fen) {
    restart();
    if (steps.isEmpty) {
      steps.add(fen);
    }
    List list = fen.split('/');
    int y = 0;
    for (String line in list) {
      int x = 0;
      for (int i = 0; i < line.length; i++) {
        String p = line[i];
        var value = int.tryParse(p);
        if (value == null) {
          if (x + i < 9 && y < 10) {
            map.add(Chess(y, x + i, p));
          }
        } else {
          x += value - 1;
        }
      }
      y++;
    }
  }

  Point translate(double x, double y, double w, double h) {
    x -= (w - boardWidth - boxWidth - gridSize) / 2;
    y -= (h - boardHeight) / 2;
    int row = (y - coordinateHeight) ~/ gridSize;
    int col = x ~/ gridSize;
    return Point(row, col);
  }

  Chess? targetChess(Point p) {
    for (Chess chess in map) {
      if (chess.col == p.col && chess.row == p.row) {
        return chess;
      }
    }
    return null;
  }

  bool canSel(Chess? chess) {
    return chess?.isRed == redGo;
  }

  void addTrack(Point p) {
    tracks.add(p);
    if (tracks.pair.length == 1) {
      clearPM();
    }
  }

  void clearPM() {
    possibleMove.clear();
  }

  List<Point> canGoList(Chess chess) {
    List<Point> goList = [];
    for (int col = 0; col < 9; col++) {
      for (int row = 0; row < 10; row++) {
        if (canMove(chess, row, col)) {
          goList.add(Point(row, col));
        }
      }
    }

    clearAttack(goList, chess);
    return goList;
  }

  bool noneChess(int row, int col) {
    Chess? target = targetChess(Point(row, col));
    return target == null;
  }

  bool emptyOrCanEat(Chess chess, int row, int col) {
    return noneChess(row, col) || canEat(chess, row, col);
  }

  bool canEat(Chess chess, int row, int col) {
    Chess? target = targetChess(Point(row, col));
    if (target != null) {
      if (chess.isRed != target.isRed) {
        return true;
      }
    }
    return false;
  }

  bool step(Chess chess, int row, int col) {
    if (chess.col == col && (chess.row - row).abs() == 1) {
      return true;
    }
    if (chess.row == row && (chess.col - col).abs() == 1) {
      return true;
    }
    return false;
  }

  bool kingMove(Chess chess, int row, int col) {
    if (emptyOrCanEat(chess, row, col)) {
      if (chess.isRed) {
        if (row < 7 || col < 3 || col > 5) {
          return false;
        } else {
          return step(chess, row, col);
        }
      } else {
        if (row > 2 || col < 3 || col > 5) {
          return false;
        } else {
          return step(chess, row, col);
        }
      }
    }
    return false;
  }

  bool advisorMove(Chess chess, int row, int col) {
    if (emptyOrCanEat(chess, row, col)) {
      if (chess.isRed) {
        if (chess.row == 7 || chess.row == 9) {
          if (row == 8 && col == 4) {
            return true;
          }
        }
        if (chess.row == 8) {
          if (row == 7 && col == 3) {
            return true;
          }
          if (row == 9 && col == 3) {
            return true;
          }
          if (row == 7 && col == 5) {
            return true;
          }
          if (row == 9 && col == 5) {
            return true;
          }
        }
      } else {
        if (chess.row == 2 || chess.row == 0) {
          if (row == 1 && col == 4) {
            return true;
          }
        }
        if (chess.row == 1) {
          if (row == 2 && col == 3) {
            return true;
          }
          if (row == 0 && col == 3) {
            return true;
          }
          if (row == 2 && col == 5) {
            return true;
          }
          if (row == 0 && col == 5) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool validBishopMove(Chess chess, int row, int col) {
    if (chess.col > col) {
      if (chess.row > row) {
        if (noneChess(row + 1, col + 1)) {
          return true;
        }
      }
      if (chess.row < row) {
        if (noneChess(row - 1, col + 1)) {
          return true;
        }
      }
    }
    if (chess.col < col) {
      if (chess.row > row) {
        if (noneChess(row + 1, col - 1)) {
          return true;
        }
      }
      if (chess.row < row) {
        if (noneChess(row - 1, col - 1)) {
          return true;
        }
      }
    }
    return false;
  }

  bool bishopMove(Chess chess, int row, int col) {
    if (emptyOrCanEat(chess, row, col)) {
      if (chess.isRed) {
        if (row > 4) {
          if (chess.col - col == 2 && chess.row - row == 2) {
            return validBishopMove(chess, row, col);
          }
          if (chess.col - col == -2 && chess.row - row == -2) {
            return validBishopMove(chess, row, col);
          }
          if (chess.col - col == -2 && chess.row - row == 2) {
            return validBishopMove(chess, row, col);
          }
          if (chess.col - col == 2 && chess.row - row == -2) {
            return validBishopMove(chess, row, col);
          }
        }
      } else {
        if (row < 5) {
          if (chess.col - col == 2 && chess.row - row == 2) {
            return validBishopMove(chess, row, col);
          }
          if (chess.col - col == -2 && chess.row - row == -2) {
            return validBishopMove(chess, row, col);
          }
          if (chess.col - col == -2 && chess.row - row == 2) {
            return validBishopMove(chess, row, col);
          }
          if (chess.col - col == 2 && chess.row - row == -2) {
            return validBishopMove(chess, row, col);
          }
        }
      }
    }
    return false;
  }

  bool validKnightMove(Chess chess, int row, int col) {
    if ((chess.col - col).abs() == 1) {
      if (chess.row - row == 2) {
        if (noneChess(row + 1, chess.col)) {
          return true;
        }
      }
      if (chess.row - row == -2) {
        if (noneChess(row - 1, chess.col)) {
          return true;
        }
      }
    }
    if ((chess.row - row).abs() == 1) {
      if (chess.col - col == 2) {
        if (noneChess(chess.row, col + 1)) {
          return true;
        }
      }
      if (chess.col - col == -2) {
        if (noneChess(chess.row, col - 1)) {
          return true;
        }
      }
    }
    return false;
  }

  bool knightMove(Chess chess, int row, int col) {
    if (emptyOrCanEat(chess, row, col)) {
      if (pow(chess.col - col, 2) + pow(chess.row - row, 2) == 5) {
        return validKnightMove(chess, row, col);
      }
    }
    return false;
  }

  bool validRookMove(Chess chess, int row, int col) {
    if (chess.row == row) {
      if (chess.col != col) {
        return hasBetweenChess(row, min(col, chess.col), max(col, chess.col),
                vertical: false) ==
            0;
      }
    }
    if (chess.col == col) {
      if (chess.row != row) {
        return hasBetweenChess(col, min(row, chess.row), max(row, chess.row)) ==
            0;
      }
    }
    return false;
  }

  bool rookMove(Chess chess, int row, int col) {
    if (emptyOrCanEat(chess, row, col)) {
      if (validRookMove(chess, row, col)) {
        if (chess.row == row && chess.col != col) {
          return true;
        }
        if (chess.row != row && chess.col == col) {
          return true;
        }
      }
    }
    return false;
  }

  int hasBetweenChess(int same, int start, int end, {bool vertical = true}) {
    for (int i = start + 1; i < end; i++) {
      if (vertical) {
        if (!noneChess(i, same)) {
          return i;
        }
      } else {
        if (!noneChess(same, i)) {
          return i;
        }
      }
    }
    return 0;
  }

  bool validCannonMove(Chess chess, int row, int col) {
    if (canEat(chess, row, col)) {
      if (chess.col == col) {
        if ((chess.row - row).abs() > 1) {
          int i =
              hasBetweenChess(col, min(row, chess.row), max(row, chess.row));
          if (i > 0) {
            return hasBetweenChess(col, i, max(row, chess.row)) == 0;
          }
        }
      }
      if (chess.row == row) {
        if ((chess.col - col).abs() > 1) {
          int i = hasBetweenChess(row, min(col, chess.col), max(col, chess.col),
              vertical: false);
          if (i > 0) {
            return hasBetweenChess(row, i, max(col, chess.col),
                    vertical: false) ==
                0;
          }
        }
      }
    }
    return false;
  }

  bool cannonMove(Chess chess, int row, int col) {
    if (noneChess(row, col)) {
      if (chess.col == col && chess.row != row) {
        return hasBetweenChess(col, min(row, chess.row), max(row, chess.row)) ==
            0;
      }
      if (chess.col != col && chess.row == row) {
        return hasBetweenChess(row, min(col, chess.col), max(col, chess.col),
                vertical: false) ==
            0;
      }
    } else {
      if (chess.col == col && chess.row != row) {
        return validCannonMove(chess, row, col);
      }
      if (chess.col != col && chess.row == row) {
        return validCannonMove(chess, row, col);
      }
    }
    return false;
  }

  bool pawnMove(Chess chess, int row, int col) {
    if (emptyOrCanEat(chess, row, col)) {
      if (chess.isRed) {
        if (chess.row > row) {
          return chess.col == col && chess.row - row == 1;
        }
        if (chess.row == row) {
          if (row < 5) {
            return step(chess, row, col);
          }
        }
      } else {
        if (chess.row < row) {
          return chess.col == col && row - chess.row == 1;
        }
        if (chess.row == row) {
          if (row > 4) {
            return step(chess, row, col);
          }
        }
      }
    }
    return false;
  }

  bool canMove(Chess chess, int row, int col) {
    switch (chess.name) {
      case 'p':
      case 'P':
        return pawnMove(chess, row, col);
      case 'c':
      case 'C':
        return cannonMove(chess, row, col);
      case 'r':
      case 'R':
        return rookMove(chess, row, col);
      case 'n':
      case 'N':
        return knightMove(chess, row, col);
      case 'b':
      case 'B':
        return bishopMove(chess, row, col);
      case 'a':
      case 'A':
        return advisorMove(chess, row, col);
      case 'k':
      case 'K':
        return kingMove(chess, row, col);
      default:
        break;
    }
    return false;
  }

  Chess? kingChess(Chess chess) {
    for (Chess king in map) {
      if (chess.isRed) {
        if (king.name == 'k') {
          return king;
        }
      } else {
        if (king.name == 'K') {
          return king;
        }
      }
    }
    return null;
  }

  bool kingFaceAttack(Chess chess, int row, int col) {
    if (chess.col == col && chess.row != row) {
      if (hasBetweenChess(col, min(row, chess.row), max(row, chess.row)) == 0) {
        return true;
      }
    }
    return false;
  }

  bool canAttack(Chess enemy, int row, int col) {
    switch (enemy.name) {
      case 'p':
      case 'P':
        return pawnMove(enemy, row, col);
      case 'c':
      case 'C':
        return cannonMove(enemy, row, col);
      case 'r':
      case 'R':
        return rookMove(enemy, row, col);
      case 'n':
      case 'N':
        return knightMove(enemy, row, col);
      case 'k':
      case 'K':
        return kingFaceAttack(enemy, row, col);
      default:
        break;
    }
    return false;
  }

  Point attackKingPos(Chess enemy, int row, int col, Chess chess) {
    Chess? king = kingChess(enemy);
    Point p = Point(-1, -1);
    int? krow = king?.row;
    int? kcol = king?.col;
    Point tp = Point(chess.row, chess.col);
    if (chess.name == 'k' || chess.name == 'K') {
      Chess? temp = targetChess(Point(row, col));
      if (!noneChess(row, col)) {
        temp?.col = -1;
        temp?.row = -1;
      } else {
        chess.col = col;
        chess.row = row;
      }
      if (canAttack(enemy, row, col)) {
        p.row = row;
        p.col = col;
      }
      chess.col = tp.col;
      chess.row = tp.row;
      if (temp != null) {
        temp.col = col;
        temp.row = row;
      }
    } else {
      chess.col = col;
      chess.row = row;
      if (canAttack(enemy, krow!, kcol!)) {
        //如果可以吃掉正在将军的敌棋,则不用清除
        if (!canEat(chess, row, col)) {
          if (enemy.row != row || enemy.col != col) {
            p.row = row;
            p.col = col;
          }
        } else {
          Chess? eat = targetChess(Point(row, col));
          //正在将军的棋子不能清除
          if (!canAttack(eat!, krow, kcol)) {
            p.row = row;
            p.col = col;
          }
        }
      }
      chess.col = tp.col;
      chess.row = tp.row;
    }
    return p;
  }

  void clearAttack(List<Point> v, Chess chess) {
    List<Point> attackingPos = [];
    List<Chess> chesses = List<Chess>.from(map);
    var enemies = chesses.where((element) {
      return element.isRed != chess.isRed;
    });
    for (Point pt in v) {
      for (Chess enemy in enemies) {
        Point p = attackKingPos(enemy, pt.row, pt.col, chess);
        if (p.row != -1 && p.col != -1) {
          attackingPos.add(p);
        }
      }
    }
    for (Point p in attackingPos) {
      v.removeWhere((element) {
        return p.row == element.row && p.col == element.col;
      });
    }
  }

  bool win(Chess chess) {
    for (Chess enemy in map) {
      if (enemy.isRed != chess.isRed) {
        List<Point> goList = canGoList(enemy);
        if (goList.isNotEmpty) return false;
      }
    }
    return true;
  }

  bool tryEndGame() {
    Chess chess = driveChess;
    if (win(chess)) {
      Chess? king = kingChess(chess);
      king?.dead = true;
      return true;
    }
    return false;
  }

  void setDriveChess(Chess chess) {
    driveChess = chess;
  }

  bool attacked(Chess chess) {
    for (Chess ch in map) {
      if (ch.name == 'k' || ch.name == 'K') {
        if (ch.attacked) {
          ch.attacked = false;
        }
      }
      Chess? king = kingChess(chess);
      if (canAttack(ch, king!.row, king.col)) {
        return true;
      }
    }
    return false;
  }

  PreStave buildPrefix(Chess chess) {
    List<Chess> temp = [];
    String name = chess.name;
    if (name == 'K' ||
        name == 'k' ||
        name == 'a' ||
        name == 'A' ||
        name == 'B' ||
        name == 'b') {
      return PreStave.none;
    }
    for (Chess other in map) {
      if (other.name == chess.name) {
        if (other.col == chess.col && other.row != chess.row) {
          temp.add(other);
        }
      }
    }

    int ret = temp.length;
    if (ret == 0) {
      return PreStave.none;
    } else if (ret == 1) {
      Chess other = temp.last;
      if (chess.row > other.row) {
        if (chess.isRedChess()) {
          return PreStave.end;
        } else {
          return PreStave.front;
        }
      } else {
        if (chess.isRedChess()) {
          return PreStave.front;
        } else {
          return PreStave.end;
        }
      }
    } else if (ret == 2) {
      Chess first = temp.first;
      Chess second = temp.last;
      if (chess.row < first.row && chess.row < second.row) {
        if (chess.isRedChess()) {
          return PreStave.front;
        } else {
          return PreStave.end;
        }
      } else if (chess.row < max(first.row, second.row) &&
          chess.row > min(first.row, second.row)) {
        return PreStave.middle;
      } else {
        if (chess.isRedChess()) {
          return PreStave.end;
        } else {
          return PreStave.front;
        }
      }
    }
    return PreStave.none;
  }

  String buildStave(Chess chess, Point newPos, PreStave prefix) {
    String stave = chessNames[chess.name];
    if (chess.isRedChess()) {
      stave += coordinate[chess.col];
      if (chess.row == newPos.row) {
        stave += "平";
        stave += coordinate[newPos.col];
      } else if (chess.row > newPos.row) {
        stave += "进";
      } else {
        stave += "退";
      }
    } else {
      stave += (chess.col + 1).toString();
      if (chess.row == newPos.row) {
        stave += "平";
        stave += (newPos.col + 1).toString();
      } else if (chess.row < newPos.row) {
        stave += "进";
      } else {
        stave += "退";
      }
    }

    if (chess.row != newPos.row) {
      if (chess.name == 'N' || chess.name == 'B' || chess.name == 'A') {
        stave += coordinate[newPos.col];
      } else if (chess.name == 'n' || chess.name == 'b' || chess.name == 'a') {
        stave += (newPos.col + 1).toString();
      } else {
        if (chess.isRedChess()) {
          stave += coordinate[9 - (chess.row - newPos.row).abs()];
        } else {
          stave += ((chess.row - newPos.row).abs()).toString();
        }
      }
    }

    switch (prefix) {
      case PreStave.front:
        stave = "前${stave.substring(0, 1)}${stave.substring(2)}";
        break;
      case PreStave.end:
        stave = "后${stave.substring(0, 1)}${stave.substring(2)}";
        break;
      case PreStave.middle:
        stave = "中${stave.substring(0, 1)}${stave.substring(2)}";
        break;
      case PreStave.none:
      default:
        break;
    }

    return stave;
  }

  void genarateStave() {
    stave = "";
    for (int i = 0; i < staves.length; i++) {
      if (i % 2 == 0) {
        stave += "${i ~/ 2 + 1}. ${staves[i]}";
      } else {
        stave += "  ${staves[i]}\n";
      }
    }
  }

  void goChess(Point p) {
    addTrack(p);
    Chess? chess = driveChess;
    /*if (source.row > -1) {
      chess = targetChess(source);
      setDriveChess(chess!);
      addTrack(source);
    }*/
    PreStave prefix = buildPrefix(chess);
    String stave = buildStave(chess, p, prefix);
    staves.add(stave);
    genarateStave();
    map.removeWhere((element) {
      return p.row == element.row && p.col == element.col;
    });
    chess.col = p.col;
    chess.row = p.row;

    redGo = !redGo;
    possibleMove.clear();
    String m = buildFen();
    steps.add(m);
    if (attacked(chess)) {
      Chess? king = kingChess(chess);
      king?.attacked = true;
    }
  }

  bool containsPM(Point p) {
    for (Point e in possibleMove) {
      if (e.col == p.col && e.row == p.row) {
        return true;
      }
    }
    return false;
  }

  void backStep() {
    if (steps.length > 1) {
      steps.removeLast();
      drawFromFen(steps.last);
      staves.removeLast();
      genarateStave();
      tracks.clear();
      redGo = !redGo;
    }
  }

  String buildFen() {
    String fen = "";
    List<List<Chess>> lines = [];

    for (int i = 0; i < 10; i++) {
      List<Chess> line = [];
      for (Chess chess in map) {
        if (chess.row == i) {
          line.add(chess);
        }
      }
      lines.add(line);
    }
    for (List<Chess> lmap in lines) {
      lmap.sort((a, b) => a.col.compareTo(b.col));

      String sline = "";
      int i = 0;
      for (Chess s in lmap) {
        if (i == 0) {
          if (s.col > 0) {
            String tmp = s.col.toString();
            sline += tmp;
            sline += s.name;
          } else {
            sline += s.name;
          }
        } else {
          int num = s.col - lmap[i - 1].col;
          if (num > 1) {
            String tmp = (num - 1).toString();
            sline += tmp;
            sline += s.name;
          } else {
            sline += s.name;
          }
        }
        i++;
      }
      if (sline.isEmpty) {
        sline = "9";
      } else {
        int pos = 0;
        for (int i = 0; i < sline.length; i++) {
          String c = sline[i];
          var value = int.tryParse(c);
          if (value != null) {
            pos += value;
          } else {
            pos++;
          }
        }
        if (pos < 9) {
          String ret = (9 - pos).toString();
          sline += ret;
        }
      }
      fen += '$sline/';
    }
    fen.substring(0, fen.length - 1);
    fen += " b - - 0 1";
    return fen;
  }

  void start(Point p) {
    Chess? chess = targetChess(p);
    bool canGO = containsPM(p);
    if (canGO) {
      goChess(p);
      //AI go...
      /*std::string str;
    string fen = StringUtil::buildFen(game->map);
    str = con.getNextMove(fen);
    while (str == "error" || str == aiMove)
    {
    str = con.getNextMove(fen);
    printf("str:%s\n", str.c_str());
    }
    aiMove = str;
    Point source = Board::toCoord(str[0], str[1]);
    Point target = Board::toCoord(str[2], str[3]);
      goChess(target, source);*/
    } else {
      if (chess != null) {
        if (canSel(chess)) {
          addTrack(p);
          List<Point> goList = canGoList(chess);
          possibleMove.addAll(goList);
          setDriveChess(chess);
        }
      }
    }
  }
}
