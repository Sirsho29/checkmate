import 'package:checkmate/globals/navigation/navigator_services.dart';
import 'package:checkmate/providers/auth_provider.dart';
import 'package:checkmate/screens/chess_board.dart/chess_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  HomePage({Key key}) : super(key: key);

  final NavigatorService _navigatorService = NavigatorService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text("Home"),
            ElevatedButton(
              onPressed: () {
                _navigatorService.navigate(context, const NewChessBoard());
              },
              child: const Text("PLAY"),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthProvider>().signout(context);
              },
              child: const Text("LOGOUT"),
            ),
          ],
        ),
      ),
    );
  }
}
