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
  int wTime, bTime = 600;

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
      "wTime": 600,
      "bTime": 600,
      "win": null,
      "msg": null,
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // controller.
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          Image.asset('assets/logo/1.png'),
        ],
        title: Text(
          "Online Multiplayer",
          style: TextStyle(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
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
                    "wDp": doc["wDp"] ?? _userAuth.currentUser.photoURL,
                    "wName": doc["wName"] ?? _userAuth.currentUser.displayName,
                    "bDp": doc["wDp"] == null
                        ? null
                        : _userAuth.currentUser.photoURL,
                    "bName": doc["wName"] == null
                        ? null
                        : _userAuth.currentUser.displayName,
                    "black":
                        doc["white"] == null ? null : _userAuth.currentUser.uid,
                    "move": "w",
                    "wTime": 600,
                    "bTime": 600,
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
                    "bDp": _userAuth.currentUser.photoURL,
                    "bName": _userAuth.currentUser.displayName,
                    "move": "w",
                    "wTime": 600,
                    "bTime": 600,
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
                    SizedBox(
                      height: 20.0,
                    ),
                    if (doc["white"] != null && doc["black"] != null)
                      UserContainerGameBoard(
                        isMe: false,
                        image: doc["white"] == _userAuth.currentUser.uid
                            ? doc["bDp"]
                            : doc["wDp"],
                        username: doc["white"] == _userAuth.currentUser.uid
                            ? doc["bName"] ?? "User 2"
                            : doc["wName"] ?? "User 2",
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
                          boardColor: BoardColor.brown,
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
                        image: _userAuth.currentUser.photoURL,
                        username: _userAuth.currentUser.displayName,
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
      "Time Left : " + time.toString(),
      style: TextStyle(color: Colors.white70),
    );
  }
}

class UserContainerGameBoard extends StatelessWidget {
  final String username;
  final String image;
  final Widget time;
  final bool isMe;
  const UserContainerGameBoard(
      {Key key, this.image, this.time, this.username = "", this.isMe = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            child: Image.network(
              image,
              fit: BoxFit.cover,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(color: Colors.white),
              ),
              time
            ],
          ),
        ),
        if (isMe)
          CircleAvatar(
            child: Image.network(
              image,
              fit: BoxFit.cover,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
      ],
    );
  }
}
