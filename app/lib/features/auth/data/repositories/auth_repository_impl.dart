import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({IAuthRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? FirebaseAuthRemoteDataSource();

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  AppUser? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<AppUser> signInAnonymously() async {
    try {
      return await _remoteDataSource.signInAnonymously();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e.code);
    } catch (e) {
      throw AuthFailure('Error inesperado al iniciar sesión anónima: $e');
    }
  }

  @override
  Future<AppUser> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _remoteDataSource.signInWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e.code);
    } catch (e) {
      throw AuthFailure('Error inesperado al iniciar sesión: $e');
    }
  }

  @override
  Future<AppUser> registerWithEmailAndPassword(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      return await _remoteDataSource.registerWithEmailAndPassword(
        email,
        password,
        displayName: displayName,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e.code);
    } catch (e) {
      throw AuthFailure('Error inesperado al registrar usuario: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _remoteDataSource.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(e.message, e.code);
    } catch (e) {
      throw AuthFailure('Error inesperado al cerrar sesión: $e');
    }
  }
}
