import 'dart:async' as timer;
import 'dart:developer';
import 'package:checkmate/globals/designs/size_config.dart';
import 'package:checkmate/globals/navigation/navigator_services.dart';
import 'package:checkmate/providers/auth_provider.dart';
import 'package:checkmate/screens/home/all_players.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:provider/provider.dart';

class NewChessBoard extends StatefulWidget {
  const NewChessBoard({Key key, this.gameRoomId}) : super(key: key);

  final String gameRoomId;

  @override
  _NewChessBoardState createState() => _NewChessBoardState();
}

class _NewChessBoardState extends State<NewChessBoard>
    with WidgetsBindingObserver {
  ChessBoardController controller = ChessBoardController();
  int wTime, bTime = 600;
  final NavigatorService _navigatorService = NavigatorService();

  showWinDialog(String msg, String color) {
    controller.clearBoard();
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text(msg ?? ""),
        content: Text((color ?? "") + " won"),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("HOME"),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .update({
                'active': true,
                'request': false,
                'requestGameId': "",
                'requestPlayerId': "",
                'requestPlayerName': "",
                'requestPlayerImage': "",
                'inGame': false,
              });
              _navigatorService.clearNavigate(context, ActivePlayers());
            },
          ),
        ],
      ),
    );
  }

  showWInactiveDialog(String msg, String color) {
    controller.clearBoard();
    showPlatformDialog(
      context: context,
      builder: (_) => BasicDialogAlert(
        title: Text(msg ?? ""),
        content: Text((color ?? "") + " won"),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("HOME"),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .update({
                'active': true,
                'request': false,
                'requestGameId': "",
                'requestPlayerId': "",
                'requestPlayerName': "",
                'requestPlayerImage': "",
                'inGame': false,
              });
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

  List<String> lastMove = [];

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection("gameRooms")
        .doc(widget.gameRoomId)
        .set({
      FirebaseAuth.instance.currentUser.uid: true,
      "fen": controller.getFen(),
      "move": "w",
      "wTime": 600,
      "bTime": 600,
      "win": null,
      "msg": null,
    });

    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      FirebaseFirestore.instance
          .collection("gameRooms")
          .doc(widget.gameRoomId)
          .update({
        FirebaseAuth.instance.currentUser.uid: false,
      });
    } else {
      FirebaseFirestore.instance
          .collection("gameRooms")
          .doc(widget.gameRoomId)
          .update({
        FirebaseAuth.instance.currentUser.uid: true,
      });
    }
  }

  bool isWaitingPopupOpen = false;

  @override
  Widget build(BuildContext context) {
    // controller.
    return WillPopScope(
      onWillPop: () async {
        bool ans = await showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text("Quit Game ?"),
                  content: Text("Are you sure you want to quit the game"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text("Cancel")),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text("Yes")),
                  ],
                ));
        if (ans == null) {
          ans = false;
        }
        if (ans) {
          FirebaseFirestore.instance
              .collection("gameRooms")
              .doc(widget.gameRoomId)
              .update({
            FirebaseAuth.instance.currentUser.uid: false,
          });
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .update({
            'active': true,
            'request': false,
            'requestGameId': "",
            'requestPlayerId': "",
            'requestPlayerName': "",
            'requestPlayerImage': "",
            'inGame': false,
          });
        }
        return ans;
      },
      child: Scaffold(
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
                    .collection('gameRooms')
                    .doc(widget.gameRoomId)
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
                        .collection("gameRooms")
                        .doc(widget.gameRoomId)
                        .update({
                      "fen": controller.getFen(),
                      "white": doc["white"] ?? _userAuth.currentUser.uid,
                      "wDp": doc["wDp"] ?? _userAuth.currentUser.photoURL,
                      "wName":
                          doc["wName"] ?? _userAuth.currentUser.displayName,
                      "bDp": doc["wDp"] == null
                          ? null
                          : _userAuth.currentUser.photoURL,
                      "bName": doc["wName"] == null
                          ? null
                          : _userAuth.currentUser.displayName,
                      "black": doc["white"] == null
                          ? null
                          : _userAuth.currentUser.uid,
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
                        .collection("gameRooms")
                        .doc(widget.gameRoomId)
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
                    if (controller.isInCheck()) {
                      Future.delayed(Duration.zero).then((value) =>
                          _navigatorService.showSnackbar(
                              context, "That's a CHECK !"));
                    }
                  }

                  PlayerColor playerColor = doc["white"] == null
                      ? PlayerColor.white
                      : doc["white"] == _userAuth.currentUser.uid
                          ? PlayerColor.white
                          : PlayerColor.black;

                  if (((playerColor == PlayerColor.white &&
                              doc[doc['black']] == false) ||
                          (playerColor == PlayerColor.black &&
                              doc[doc['white']] == false)) &&
                      !isWaitingPopupOpen) {
                    isWaitingPopupOpen = true;
                    Future.delayed(Duration.zero).then((value) {
                      showDialog(
                          context: context,
                          builder: (ctx) => WaitingOponentResponseDialog(
                                gameId: widget.gameRoomId,
                                playerColor: playerColor,
                                listenToUserId: playerColor == PlayerColor.white
                                    ? doc['black']
                                    : doc['white'],
                                pageCtx: context,
                              )).then((value) {
                        Future.delayed(Duration(seconds: 1))
                            .then((value) => isWaitingPopupOpen = false);
                      });
                    });
                  }

                  if (doc['win'] != null) {
                    if ((doc['win'] == "White" &&
                            playerColor != PlayerColor.white) ||
                        (doc['win'] == "Black" &&
                            playerColor != PlayerColor.black)) {
                      Future.delayed(Duration.zero)
                          .then((value) => showWinDialog(
                                doc['msg'],
                                playerColor == PlayerColor.black
                                    ? "White"
                                    : "Black",
                              ));
                    }
                  }
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
                                    .collection("gameRooms")
                                    .doc(widget.gameRoomId)
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
                              log(controller.game.history.length.toString() +
                                  " : ${controller.game.history[0].move.fromAlgebraic} -> ${controller.game.history[0].move.toAlgebraic}");

                              if (controller.isCheckMate()) {
                                // log("Checkmate");
                                await FirebaseFirestore.instance
                                    .collection("gameRooms")
                                    .doc(widget.gameRoomId)
                                    .update({
                                  "fen": controller.getFen(),
                                  "move": doc["move"] == "w" ? "b" : "w",
                                  "wTime":
                                      doc["move"] == "w" ? wTime : doc["wTime"],
                                  "bTime":
                                      doc["move"] == "b" ? bTime : doc["bTime"],
                                  "win": playerColor == PlayerColor.black
                                      ? "Black"
                                      : "White",
                                  "msg": "CHECKMATE !!",
                                  'lastMove': [
                                    controller
                                        .game.history.first.move.fromAlgebraic,
                                    controller
                                        .game.history.first.move.toAlgebraic
                                  ],
                                });
                                showWinDialog(
                                    "CHECKMATE !!",
                                    playerColor == PlayerColor.black
                                        ? "Black"
                                        : "White");
                              } else {
                                await FirebaseFirestore.instance
                                    .collection("gameRooms")
                                    .doc(widget.gameRoomId)
                                    .update({
                                  "fen": controller.getFen(),
                                  "move": doc["move"] == "w" ? "b" : "w",
                                  "wTime":
                                      doc["move"] == "w" ? wTime : doc["wTime"],
                                  "bTime":
                                      doc["move"] == "b" ? bTime : doc["bTime"],
                                  'lastMove': [
                                    controller
                                        .game.history.first.move.fromAlgebraic,
                                    controller
                                        .game.history.first.move.toAlgebraic
                                  ],
                                });
                              }
                            },
                            boardOrientation: playerColor,
                            arrows: [
                              if (doc.containsKey('lastMove') &&
                                  doc['lastMove'].length == 2)
                                BoardArrow(
                                    from: doc['lastMove'][0],
                                    to: doc['lastMove'][1],
                                    color: Colors.black.withOpacity(0.3))
                            ],
                          ),
                        ),
                      ),
                      // if (controller.game.history.length > 0)
                      TextButton(
                          onPressed: () {
                            // print(controller.game.history.length);
                            // print(
                            //     " ${controller.game.history[0].move.fromAlgebraic} -> ${controller.game.history[0].move.toAlgebraic}");
                            // setState(() {
                            //   lastMove = [
                            //     controller
                            //         .game.history.first.move.fromAlgebraic,
                            //     controller.game.history.first.move.toAlgebraic
                            //   ];
                            // });
                            // print(lastMove);
                          },
                          child: Text(
                            "Show last move",
                            style: TextStyle(color: Colors.white),
                          )),
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
                                    .collection("gameRooms")
                                    .doc(widget.gameRoomId)
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

class WaitingOponentResponseDialog extends StatelessWidget {
  WaitingOponentResponseDialog(
      {Key key,
      this.listenToUserId,
      this.gameId,
      this.playerColor,
      this.pageCtx})
      : super(key: key);

  final String listenToUserId, gameId;
  final PlayerColor playerColor;
  final BuildContext pageCtx;

  final NavigatorService _navigatorService = NavigatorService();

  showWinDialog(
    String msg,
    String color,
  ) {
    showPlatformDialog(
      context: pageCtx,
      builder: (_) => BasicDialogAlert(
        title: Text(msg ?? ""),
        content: Text((color ?? "") + " won"),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text("HOME"),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("Users")
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .update({
                'active': true,
                'request': false,
                'requestGameId': "",
                'requestPlayerId': "",
                'requestPlayerName': "",
                'requestPlayerImage': "",
                'inGame': false,
              });
              _navigatorService.clearNavigate(pageCtx, ActivePlayers());
              // Navigator.of(context).pop();
              // Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    timer.Timer _timer = timer.Timer(Duration(seconds: 10), () {
      Navigator.pop(
        context,
      );
      showWinDialog("Opponent left !!",
          playerColor == PlayerColor.black ? "Black" : "White");
      FirebaseFirestore.instance.collection("gameRooms").doc(gameId).update({
        "win": playerColor == PlayerColor.black ? "Black" : "White",
        "msg": "You left the game!!",
      });
    });

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Container(
          color: Colors.white,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("gameRooms")
                  .doc(gameId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator());
                }
                if (snapshot.data[listenToUserId]) {
                  _timer.cancel();
                  // _navigatorService.pop(context);
                  Future.delayed(Duration.zero)
                      .then((value) => _navigatorService.pop(context));
                }
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        child: StreamBuilder<int>(
                            stream: Stream<int>.periodic(Duration(seconds: 1)),
                            builder: (context, snap) {
                              return Stack(
                                children: [
                                  SizedBox(
                                    height: 200.0,
                                    width: 200.0,
                                    child: CircularProgressIndicator(
                                      value: (i++) / 10,
                                      backgroundColor: Colors.black12,
                                      color: Colors.redAccent,
                                      strokeWidth: 10,
                                    ),
                                  ),
                                  Center(
                                      child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        "${10 - i + 1} s",
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Text(
                                        "Waiting for opponent...",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  )),
                                ],
                              );
                            }),
                        height: 200.0,
                        width: 200.0,
                      ),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}
