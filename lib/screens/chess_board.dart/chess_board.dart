import 'dart:async' as timer;
import 'package:checkmate/globals/designs/size_config.dart';
import 'package:checkmate/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';

class NewChessBoard extends StatefulWidget {
  const NewChessBoard({Key key}) : super(key: key);

  @override
  _NewChessBoardState createState() => _NewChessBoardState();
}

class _NewChessBoardState extends State<NewChessBoard> {
  ChessBoardController controller = ChessBoardController();
  int wTime, bTime = 300;

  showWinDialog(String msg, String color) {
    controller.clearBoard();
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text(msg ?? ""),
        content: Text((color ?? "") + " won"),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("RESET"),
            onPressed: () {
              Navigator.pop(
                context,
              );
              Navigator.pop(
                context,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    FirebaseFirestore.instance.collection("modelGames").doc("testgame").set({
      "fen": controller.getFen(),
      "move": "w",
      "wTime": 300,
      "bTime": 300,
      "win": null,
      "msg": null,
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // controller.
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: Consumer<AuthProvider>(builder: (context, _userAuth, _) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('modelGames')
                  .doc("testgame")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                        height: 100,
                        width: 100,
                        child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("ERROR!!!"));
                }
                Map<String, dynamic> doc = snapshot.data.data();
                if (doc['fen'] == null ||
                    doc["white"] == null ||
                    doc['black'] == null) {
                  FirebaseFirestore.instance
                      .collection("modelGames")
                      .doc("testgame")
                      .update({
                    "fen": controller.getFen(),
                    "white": doc["white"] ?? _userAuth.currentUser.uid,
                    "black":
                        doc["white"] == null ? null : _userAuth.currentUser.uid,
                    "move": "w",
                    "wTime": 300,
                    "bTime": 300,
                    "win": null,
                    "msg": null,
                  });
                }
                if (doc["white"] == doc["black"] &&
                    doc["black"] != _userAuth.currentUser.uid) {
                  FirebaseFirestore.instance
                      .collection("modelGames")
                      .doc("testgame")
                      .update({
                    "black": _userAuth.currentUser.uid,
                    "move": "w",
                    "wTime": 300,
                    "bTime": 300,
                    "win": null,
                    "msg": null,
                  });
                }
                if (doc["fen"] != null) {
                  controller.loadFen(doc["fen"]);
                }

                PlayerColor playerColor = doc["white"] == null
                    ? PlayerColor.white
                    : doc["white"] == _userAuth.currentUser.uid
                        ? PlayerColor.white
                        : PlayerColor.black;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (doc["white"] != null && doc["black"] != null)
                      UserContainerGameBoard(
                        image: "test",
                        username: "User 2",
                        time: ChessTimer(
                          init: doc["white"] == _userAuth.currentUser.uid
                              ? doc["bTime"]
                              : doc["wTime"],
                          isRunning: !((doc["move"] == "w" &&
                                  playerColor == PlayerColor.white) ||
                              (doc["move"] == "b" &&
                                  playerColor == PlayerColor.black)),
                          onChange: (v) async {
                            if (doc["white"] == _userAuth.currentUser.uid) {
                              bTime = v;
                            } else {
                              wTime = v;
                            }
                            if (v == 0) {
                              showWinDialog(
                                  "Timer ended!!",
                                  playerColor == PlayerColor.black
                                      ? "Black"
                                      : "White");
                              await FirebaseFirestore.instance
                                  .collection("modelGames")
                                  .doc("testgame")
                                  .update({
                                "win": playerColor == PlayerColor.black
                                    ? "Black"
                                    : "White",
                                "msg": "Timer ended!!",
                              });
                            }
                          },
                        ),
                      ),
                    Expanded(
                      child: Center(
                        child: ChessBoard(
                          controller: controller,
                          boardColor: BoardColor.orange,
                          enableUserMoves: (doc["move"] == "w" &&
                                  playerColor == PlayerColor.white) ||
                              (doc["move"] == "b" &&
                                  playerColor == PlayerColor.black),
                          onMove: () async {
                            await FirebaseFirestore.instance
                                .collection("modelGames")
                                .doc("testgame")
                                .update({
                              "fen": controller.getFen(),
                              "move": doc["move"] == "w" ? "b" : "w",
                              "wTime":
                                  doc["move"] == "w" ? wTime : doc["wTime"],
                              "bTime":
                                  doc["move"] == "b" ? bTime : doc["bTime"],
                            });
                          },
                          boardOrientation: playerColor,
                        ),
                      ),
                    ),
                    if (doc["white"] != null && doc["black"] != null)
                      UserContainerGameBoard(
                        image: "test",
                        username: "User 1",
                        time: ChessTimer(
                          init: doc["white"] == _userAuth.currentUser.uid
                              ? doc["wTime"]
                              : doc["bTime"],
                          isRunning: (doc["move"] == "w" &&
                                  playerColor == PlayerColor.white) ||
                              (doc["move"] == "b" &&
                                  playerColor == PlayerColor.black),
                          onChange: (v) async {
                            if (doc["white"] == _userAuth.currentUser.uid) {
                              wTime = v;
                            } else {
                              bTime = v;
                            }
                            if (v == 0) {
                              showWinDialog(
                                  "Timer ended!!",
                                  playerColor == PlayerColor.black
                                      ? "White"
                                      : "Black");
                              await FirebaseFirestore.instance
                                  .collection("modelGames")
                                  .doc("testgame")
                                  .update({
                                "win": playerColor == PlayerColor.black
                                    ? "White"
                                    : "Black",
                                "msg": "Timer ended!!",
                              });
                            }
                          },
                        ),
                      ),
                    const SizedBox(
                      height: 40,
                    ),
                  ],
                );
              });
        }),
      ),
    );
  }
}

class ChessTimer extends StatefulWidget {
  const ChessTimer({this.init, this.isRunning = false, this.onChange, Key key})
      : super(key: key);

  final int init;
  final bool isRunning;
  final Function(int) onChange;

  @override
  _ChessTimerState createState() => _ChessTimerState();
}

class _ChessTimerState extends State<ChessTimer> {
  int time;
  timer.Timer _timer;
  @override
  void initState() {
    time = widget.init;
    _timer = timer.Timer.periodic(const Duration(seconds: 1), (timer.Timer t) {
      if (time > 0 && widget.isRunning) {
        if (mounted) {
          setState(() {
            time--;
          });
        }
        widget.onChange(time);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      time.toString(),
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }
}

class UserContainerGameBoard extends StatelessWidget {
  final String username;
  final String image;
  final Widget time;
  const UserContainerGameBoard(
      {Key key, this.image, this.time, this.username = ""})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Card(
        shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.orange[800]),
            borderRadius: const BorderRadius.all(Radius.circular(8.0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // add this
          children: <Widget>[
            // Container(
            //   height: 70,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.only(
            //         topLeft: Radius.circular(8.0),
            //         topRight: Radius.circular(8.0)),
            //     image: DecorationImage(
            //       fit: BoxFit.fill,
            //       image: image == null || image == "test"
            //           ? AssetImage(
            //               'assets/images/playerProfile.jpg',
            //               // width: 300,
            //             )
            //           : CachedNetworkImageProvider(
            //               image,
            //             ),
            //     ),
            //   ),
            // ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    color: Colors.orange[900]),
                child: Center(
                  child: time,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
