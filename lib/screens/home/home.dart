import 'package:checkmate/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key key}) : super(key: key);

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
