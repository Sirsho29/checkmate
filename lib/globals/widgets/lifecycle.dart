import 'package:checkmate/globals/designs/theme.dart';
import 'package:checkmate/screens/auth/splash.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class LifecycleWatcher extends StatefulWidget {
  @override
  _LifecycleWatcherState createState() => _LifecycleWatcherState();
}

class _LifecycleWatcherState extends State<LifecycleWatcher>
    with WidgetsBindingObserver {
  // AppLifecycleState _lastLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (FirebaseAuth.instance.currentUser != null) {
      if (state == AppLifecycleState.detached ||
          state == AppLifecycleState.inactive ||
          state == AppLifecycleState.paused) {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
          'active': false,
          'request': false,
          'requestGameId': "",
          'requestPlayerId': "",
          'requestPlayerName': "",
          'requestPlayerImage': "",
          'playerName': FirebaseAuth.instance.currentUser.displayName,
          'playerImage': FirebaseAuth.instance.currentUser.photoURL,
          'inGame': false,
          'playerId': FirebaseAuth.instance.currentUser.uid,
        });
      } else {
        FirebaseFirestore.instance
            .collection("Users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
          'active': true,
          'request': false,
          'requestGameId': "",
          'requestPlayerId': "",
          'requestPlayerName': "",
          'requestPlayerImage': "",
          'inGame': false,
          'playerName': FirebaseAuth.instance.currentUser.displayName,
          'playerImage': FirebaseAuth.instance.currentUser.photoURL,
          'playerId': FirebaseAuth.instance.currentUser.uid,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppTheme>(builder: (context, theme, _) {
      return MaterialApp(
        title: 'Chekmate',
        themeMode: theme.getCurrentThemeMode(),
        theme: theme.lightTheme(),
        darkTheme: theme.darkTheme(),
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
      );
    });
  }
}
