import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();

  Future<GoogleSignInAccount?> signIn() async {
    try {
      return await _googleSignIn.signIn();
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
