import 'dart:async';

import 'package:checkmate/globals/designs/size_config.dart';
import 'package:checkmate/globals/navigation/navigator_services.dart';
import 'package:checkmate/globals/widgets/appbar.dart';
import 'package:checkmate/globals/widgets/loader.dart';
import 'package:checkmate/screens/chess_board.dart/chess_board.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ActivePlayers extends StatelessWidget {
  const ActivePlayers({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabViewScaffold(
      tabList: [
        Tab(text: "Active Players"),
        Tab(text: "Inactive Players"),
      ],
      title: "Active players",
      startIndex: 0,
      children: [
        PlayersTab(),
        PlayersTab(
          isActive: false,
        ),
      ],
    );
  }
}

class PlayersTab extends StatelessWidget {
  const PlayersTab({Key key, this.isActive = true}) : super(key: key);

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .where('active', isEqualTo: isActive)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
                height: 100, width: 100, child: CircularProgressIndicator());
          }
          List<Map<String, dynamic>> _all =
              snapshot.data.docs.map((e) => e.data()).toList();
          _all.removeWhere((element) =>
              element['playerId'] == FirebaseAuth.instance.currentUser.uid);

          if (_all.isEmpty) {
            return Center(
              child: Text(
                "No ${isActive ? "active" : "inactive"} players",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
              itemCount: _all.length,
              padding: const EdgeInsets.only(top: 20.0),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    backgroundImage: NetworkImage(_all[index]['playerImage']),
                  ),
                  title: Text(
                    _all[index]['playerName'],
                    style: TextStyle(color: Colors.white),
                  ),
                  trailing: !isActive
                      ? SizedBox()
                      : _all[index]['inGame']
                          ? Text(
                              "IN GAME",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 10),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(80, 30),
                                maximumSize: Size(80, 30),
                              ),
                              onPressed: () async {
                                String gameId = _all[index]['playerId'] +
                                    DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString() +
                                    FirebaseAuth.instance.currentUser.uid;
                                await FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(_all[index]['playerId'])
                                    .update({
                                  'request': true,
                                  'requestGameId': gameId,
                                  'requestPlayerId':
                                      FirebaseAuth.instance.currentUser.uid,
                                  'requestPlayerName': FirebaseAuth
                                      .instance.currentUser.displayName,
                                  'requestPlayerImage': FirebaseAuth
                                      .instance.currentUser.photoURL,
                                  'accepted': false,
                                });
                                showDialog(
                                    context: context,
                                    builder: (context) => SendInviteDialog(
                                          userId: _all[index]['playerId'],
                                          gameId: gameId,
                                        ));
                              },
                              child: Text(
                                "PLAY",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                );
              });
        });
  }
}

class SendInviteDialog extends StatelessWidget {
  SendInviteDialog({Key key, this.userId, this.gameId}) : super(key: key);

  final String userId, gameId;

  final NavigatorService _navigatorService = NavigatorService();

  @override
  Widget build(BuildContext context) {
    int i = 0;
    Timer _timer = Timer(Duration(seconds: 10), () {
      _navigatorService.pop(context);
    });

    return Scaffold(
      backgroundColor: Colors.black12,
      body: Center(
        child: Container(
          color: Colors.white,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator());
                }
                if (snapshot.data['accepted']) {
                  _timer.cancel();
                  // _navigatorService.pop(context);
                  Future.delayed(Duration.zero)
                      .then((value) => _navigatorService.replaceNavigate(
                            context,
                            NewChessBoard(
                              gameRoomId: gameId,
                            ),
                          ));
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
                                      color: Colors.orange,
                                      strokeWidth: 20,
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
                                        "Awaiting response ...",
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
