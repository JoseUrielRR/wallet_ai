import '../models/app_user.dart';

abstract class IAuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;

  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  });
  Future<void> signOut();
}
