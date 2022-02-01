import 'package:checkmate/globals/designs/size_config.dart';
import 'package:checkmate/globals/navigation/navigator_services.dart';
import 'package:checkmate/globals/widgets/loader.dart';
import 'package:checkmate/providers/auth_provider.dart';
import 'package:checkmate/screens/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key key}) : super(key: key);

  final NavigatorService _navigatorService = NavigatorService();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        alignment:
            Alignment.lerp(Alignment.center, Alignment.bottomCenter, 0.5),
        child: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            AuthProvider _authProvider = Provider.of<AuthProvider>(context);
            if (snapshot.connectionState == ConnectionState.waiting ||
                _authProvider.isLoggingIn) {
              return const AppLoader();
            } else if (!snapshot.hasData || snapshot.hasError) {
              return OutlinedButton.icon(
                onPressed: () async {
                  await _authProvider.loginWithGoogle(context);
                },
                icon: const Icon(Icons.facebook_outlined),
                label: const Text("Login with Google"),
                style: Theme.of(context).outlinedButtonTheme.style,
              );
            } else {
              _authProvider.initLogin(snapshot.data);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _navigatorService.replaceNavigate(context, HomePage());
              });

              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
