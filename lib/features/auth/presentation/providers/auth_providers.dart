import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';


final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      debugPrint('>>> [Auth] Starting Google Sign-In...');
      final googleUser = await GoogleSignIn().signIn();
      debugPrint('>>> [Auth] googleUser: $googleUser');
      if (googleUser == null) {
        debugPrint('>>> [Auth] User cancelled sign-in');
        state = const AsyncData(null);
        return;
      }
      debugPrint('>>> [Auth] Getting authentication tokens...');
      final googleAuth = await googleUser.authentication;
      debugPrint('>>> [Auth] accessToken: ${googleAuth.accessToken != null ? "present" : "NULL"}');
      debugPrint('>>> [Auth] idToken: ${googleAuth.idToken != null ? "present" : "NULL"}');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      debugPrint('>>> [Auth] Signing in with Firebase credential...');
      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('>>> [Auth] Sign-in SUCCESS');
      state = const AsyncData(null);
    } catch (e, st) {
      debugPrint('>>> [Auth] ERROR: $e');
      debugPrint('>>> [Auth] STACKTRACE: $st');
      state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
