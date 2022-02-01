import 'package:checkmate/globals/designs/theme.dart';
import 'package:checkmate/providers/auth_provider.dart';
import 'package:checkmate/screens/auth/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => AppTheme(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AuthProvider(),
        ),
      ],
      child: Consumer<AppTheme>(builder: (context, theme, _) {
        return MaterialApp(
          title: 'Chekmate',
          themeMode: theme.getCurrentThemeMode(),
          theme: theme.lightTheme(),
          darkTheme: theme.darkTheme(),
          home: SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      }),
    );
  }
}
