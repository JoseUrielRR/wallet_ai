import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final currentUserProvider = Provider<AppUser?>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  return authAsync.value ?? ref.watch(authRepositoryProvider).currentUser;
});

final currentUserIdProvider = Provider<String>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.id.isNotEmpty == true ? user!.id : 'demo_user';
});

class AuthController extends Notifier<AsyncValue<AppUser?>> {
  IAuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  AsyncValue<AppUser?> build() {
    final current = _repository.currentUser;
    return AsyncValue.data(current);
  }

  Future<void> signInAnonymously() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInAnonymously();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.signInWithEmailAndPassword(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> registerWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.registerWithEmailAndPassword(
        email,
        password,
        displayName: displayName,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _repository.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<AppUser?>>(() {
  return AuthController();
});
