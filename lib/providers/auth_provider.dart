import 'package:checkmate/globals/navigation/navigator_services.dart';
import 'package:checkmate/screens/auth/splash.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  User _firebaseUser;

  bool _isLoggingIn = false;

  String userId;

  final NavigatorService _navigatorService = NavigatorService();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    signInOption: SignInOption.standard,
  );

  void initLogin(User _user) {
    _firebaseUser = _user;
  }

  User get currentUser => _firebaseUser;

  bool get isLoggingIn => _isLoggingIn;

  void changeLoggingInStatus({bool changeTo, bool notify = true}) {
    _isLoggingIn = changeTo ?? !_isLoggingIn;
    if (notify) notifyListeners();
  }

  Future<void> loginWithGoogle(BuildContext ctx) async {
    try {
      changeLoggingInStatus(changeTo: true);
      GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      UserCredential _userCreds = await _auth.signInWithCredential(credential);
      _firebaseUser = _userCreds.user;
      changeLoggingInStatus(changeTo: false, notify: false);
    } on FirebaseAuthException catch (e) {
      changeLoggingInStatus(changeTo: false);
      _navigatorService.showSnackbar(ctx, e.message);
    } on PlatformException catch (e) {
      changeLoggingInStatus(changeTo: false);
      _navigatorService.showSnackbar(ctx, e.message);
    } catch (e) {
      changeLoggingInStatus(changeTo: false);
      _navigatorService.showSnackbar(ctx, e.toString());
    }
  }

  Future<void> signout(BuildContext ctx) async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
    _navigatorService.clearNavigate(
      ctx,
      SplashScreen(),
    );
  }
}
