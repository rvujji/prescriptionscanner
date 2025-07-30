// scanner/lib/auth/google_signin.dart
import 'package:google_sign_in/google_sign_in.dart';
import '../services/hive_service.dart';
import '../models/appuser.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();
  final userBox = HiveService.getUserBox();

  Future<AppUser?> signIn() async {
    try {
      // 1. Authenticate with Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // 2. Create/update AppUser in Hive
      final appUser = AppUser(
        id: googleUser.id,
        name: googleUser.displayName ?? 'Google User',
        email: googleUser.email,
        passwordHash: 'google_oauth',
        phone: '',
        dob: DateTime(1990),
        gender: 'unknown',
        country: '',
        loggedIn: true,
        accessToken: null,
        refreshToken: null,
        tokenExpiry: null,
        isSynced: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await userBox.put(appUser.id, appUser);
      return appUser;
    } catch (e) {
      print('Google Sign-In Error: $e');
      await _googleSignIn.signOut(); // Clean up on failure
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    // Clear auth tokens but keep user data
    final currentUser = HiveService.getLoggedInUser();
    if (currentUser != null) {
      await userBox.put(
        currentUser.id,
        currentUser.copyWith(
          loggedIn: false,
          accessToken: null,
          refreshToken: null,
          tokenExpiry: null,
        ),
      );
    }
  }
}
