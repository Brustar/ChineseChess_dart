import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'Board.dart';
import 'Constant.dart';
import 'Game.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize =
        Size(boardWidth + boxWidth + gridSize, boardHeight + 44);
    win.size = initialSize;
    win.alignment = Alignment.center; //将窗口显示到中间
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  Game game = Game();

  MyHomePageState() {
    game.drawFromFen(standardFen);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GestureDetector(
            child: Scaffold(
                body: Center(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      color: Colors.blue,
                      width: boardWidth,
                      alignment: Alignment.topLeft,
                      child: CustomPaint(
                        painter: Board(game),
                      ),
                    ),
                    Container(
                        color: Colors.red,
                        width: boxWidth,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0, 0, boardPadding, 0),
                          child: TextField(
                            maxLines: 22,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: game.stave,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        )),
                  ]),
            )),
            onTapUp: (e) {
              Point p = game.translate(e.localPosition.dx, e.localPosition.dy);
              game.start(p);
              if (game.tryEndGame()) {
                String msg = game.redGo ? "黑" : "紅";
                String title = game.redGo ? "輸棋" : "勝利!";
                game.staves.add("$msg勝!");
                game.genarateStave();
                msg = "$msg方勝利,要重新開始對弈嗎?";
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          title: Text(title),
                          content: Text(msg),
                          actions: [
                            OutlinedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('取消')),
                            OutlinedButton(
                                onPressed: () {
                                  game.drawFromFen(standardFen);
                                  setState(() {});
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('确定')),
                          ],
                        ));
              }
              setState(() {});
            }),
      ],
    );
  }
}
