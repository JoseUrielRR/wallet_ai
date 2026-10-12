import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/firebase/firebase_service.dart';
import '../../domain/models/app_user.dart';

abstract class IAuthRemoteDataSource {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signInAnonymously();
  Future<AppUser> signInWithEmailAndPassword(String email, String password);
  Future<AppUser> registerWithEmailAndPassword(String email, String password, {String? displayName});
  Future<void> signOut();
}

class FirebaseAuthRemoteDataSource implements IAuthRemoteDataSource {
  final FirebaseAuth? _firebaseAuth;

  FirebaseAuthRemoteDataSource({this._firebaseAuth});

  FirebaseAuth get _auth {
    if (_firebaseAuth != null) return _firebaseAuth;
    if (FirebaseService.isInitialized) {
      return FirebaseAuth.instance;
    }
    throw const AuthException(
      'Firebase no está inicializado. Configura Firebase en la aplicación.',
      'firebase-not-initialized',
    );
  }

  AppUser _mapFirebaseUser(User user) {
    return AppUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      isAnonymous: user.isAnonymous,
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  @override
  Stream<AppUser?> get authStateChanges {
    try {
      return _auth.authStateChanges().map((user) => user != null ? _mapFirebaseUser(user) : null);
    } catch (_) {
      return Stream.value(null);
    }
  }

  @override
  AppUser? get currentUser {
    try {
      final user = _auth.currentUser;
      return user != null ? _mapFirebaseUser(user) : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppUser> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No se pudo crear la sesión anónima.');
      }
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Error al iniciar sesión anónima.', e.code);
    } catch (e) {
      throw AuthException('Error inesperado al iniciar sesión: $e');
    }
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('Usuario no encontrado tras autenticación.');
      }
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Credenciales inválidas.', e.code);
    } catch (e) {
      throw AuthException('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No se pudo registrar la cuenta.');
      }
      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }
      return _mapFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Error al registrar cuenta.', e.code);
    } catch (e) {
      throw AuthException('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Error al cerrar sesión: $e');
    }
  }
}
