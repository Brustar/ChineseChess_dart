import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:file_picker/file_picker.dart';
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
    Size size = MediaQuery.of(context).size;
    TextEditingController use = TextEditingController();
    use.value = use.value.copyWith(
      text: game.stave.isEmpty ? "" : game.stave,
      selection: TextSelection(
          baseOffset: game.stave.length, extentOffset: game.stave.length),
      composing: TextRange.empty,
    );

    return Stack(
      children: <Widget>[
        GestureDetector(
            child: Scaffold(
                body: Center(
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  width: boardWidth,
                  alignment: Alignment.topLeft,
                  child: CustomPaint(
                    painter: Board(game),
                  ),
                ),
                Container(
                    width: boxWidth + boardPadding,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          5, boardPadding + coordinateHeight, boardPadding, 0),
                      child: Column(children: [
                        TextField(
                          maxLines: 22,
                          controller: use,
                          readOnly: true,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.black)),
                            focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide:
                                    BorderSide(width: 1, color: Colors.black)),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0, boardPadding, 0, 0),
                          child: Row(
                            children: [
                              MaterialButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: const Text('载入'),
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['fen'], //筛选文件类型
                                  );
                                  if (result != null) {
                                    PlatformFile f = result.files.first;
                                    File file = File(f.path!);
                                    String fen = await file.readAsString();
                                    game.drawFromFen(fen);
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                              ),
                              MaterialButton(
                                color: Colors.blue,
                                textColor: Colors.white,
                                child: const Text('打谱'),
                                onPressed: () async {
                                  FilePickerResult? result =
                                      await FilePicker.platform.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: ['fen'], //筛选文件类型
                                  );
                                  if (result != null) {
                                    PlatformFile f = result.files.first;
                                    File file = File(f.path!);
                                    String fen = await file.readAsString();
                                    game.drawFromFen(fen);
                                  } else {
                                    // User canceled the picker
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      ]),
                    )),
              ]),
            )),
            onTapUp: (e) {
              Point p = game.translate(e.localPosition.dx, e.localPosition.dy,
                  size.width, size.height);
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
