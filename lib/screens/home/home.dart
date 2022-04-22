import 'dart:async';

import 'package:checkmate/globals/designs/size_config.dart';
import 'package:checkmate/globals/navigation/navigator_services.dart';
import 'package:checkmate/providers/auth_provider.dart';
import 'package:checkmate/screens/chess_board.dart/chess_board.dart';
import 'package:checkmate/screens/home/all_players.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  final NavigatorService _navigatorService = NavigatorService();

  void setupListener(BuildContext context) {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .listen((request) {
      if (request.data()['request']) {
        Timer(Duration(seconds: 9), () {
          FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .update({
            'request': false,
            'requestGameId': "",
            'requestPlayerId': "",
            'requestPlayerName': "",
            'requestPlayerImage': "",
            'accepted': false,
          });
        });
        showTopSnackBar(
          context,
          RequestSnackbar(
            image: request.data()['requestPlayerImage'],
            name: request.data()['requestPlayerName'],
            gameId: request.data()['requestGameId'],
          ),
          displayDuration: Duration(
            seconds: 10,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    setupListener(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: SizeConfig.screenHeight,
            width: SizeConfig.screenWidth,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Color.fromARGB(255, 126, 137, 112),
                  ]),
            ),
            child: Image.asset('assets/images/home.png'),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset(
                  'assets/logo/1.png',
                  height: 200,
                  width: 200,
                ),
                // Text("")
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _navigatorService.navigate(
                              context, const ActivePlayers());
                        },
                        child: const Text(
                          "PLAY ONLINE",
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AuthProvider>().signout(context);
                        },
                        child: const Text(
                          "Logout",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestSnackbar extends StatelessWidget {
  RequestSnackbar({Key key, this.image, this.name, this.gameId})
      : super(key: key);

  final String image;
  final String name;
  final String gameId;

  final NavigatorService _navigatorService = NavigatorService();

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Container(
      clipBehavior: Clip.hardEdge,
      // height: 80,
      decoration: BoxDecoration(
        color: Colors.orange[300],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 5,
            spreadRadius: 2,
            color: Colors.black26,
          ),
        ],
      ),
      width: double.infinity,
      child: Material(
        color: Colors.orange[300],
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.redAccent,
                backgroundImage: NetworkImage(image),
              ),
              title: Text(name.split(" ").first + " wants to play with you"),
              trailing: StreamBuilder<int>(
                  stream: Stream<int>.periodic(Duration(seconds: 1)),
                  builder: (context, snap) {
                    return CircularProgressIndicator(
                      value: (i++) / 10,
                      backgroundColor: Colors.white,
                      color: Colors.redAccent,
                    );
                    // return Text("${i < 0 ? 0 : i--}");
                    // return Text("${10 - snap.data}");
                  }),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: BorderSide(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor))),
                    onPressed: () {
                      // _navigatorService.pop(context);
                    },
                    child: const Text(
                      "Decline",
                    ),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).scaffoldBackgroundColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: BorderSide(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor))),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection("Users")
                          .doc(FirebaseAuth.instance.currentUser.uid)
                          .update({
                        'request': false,
                        'inGame': true,
                        'accepted': true,
                      });
                      _navigatorService.navigate(
                        context,
                        NewChessBoard(
                          gameRoomId: gameId,
                        ),
                      );
                    },
                    child: const Text(
                      "Accept",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
