import '../../../../core/firebase/firebase_service.dart';
import '../../domain/models/user_card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasources/card_remote_datasource.dart';
import '../dtos/user_card_dto.dart';
import 'local_card_repository.dart';

class CardRepositoryImpl implements ICardRepository {
  final ICardRemoteDataSource _remoteDataSource;
  final LocalCardRepository _localFallback;
  final String Function() _getUserId;

  CardRepositoryImpl({
    ICardRemoteDataSource? remoteDataSource,
    LocalCardRepository? localFallback,
    String Function()? getUserId,
  })  : _remoteDataSource = remoteDataSource ?? FirestoreCardRemoteDataSource(),
        _localFallback = localFallback ?? LocalCardRepository(),
        _getUserId = getUserId ?? (() => 'demo_user');

  bool get _useRemote => FirebaseService.isInitialized;

  @override
  Future<List<UserCard>> getCards() async {
    if (!_useRemote) {
      return _localFallback.getCards();
    }
    try {
      final dtos = await _remoteDataSource.getCards(_getUserId());
      return dtos.map((d) => d.toDomain()).toList();
    } catch (_) {
      return _localFallback.getCards();
    }
  }

  @override
  Stream<List<UserCard>> watchCards() {
    if (!_useRemote) {
      return _localFallback.watchCards();
    }
    try {
      return _remoteDataSource.watchCards(_getUserId()).map((dtos) {
        return dtos.map((d) => d.toDomain()).toList();
      }).handleError((_) {
        return _localFallback.watchCards();
      });
    } catch (_) {
      return _localFallback.watchCards();
    }
  }

  @override
  Future<UserCard?> getCardById(String id) async {
    if (!_useRemote) {
      return _localFallback.getCardById(id);
    }
    try {
      final dto = await _remoteDataSource.getCardById(_getUserId(), id);
      return dto?.toDomain() ?? await _localFallback.getCardById(id);
    } catch (_) {
      return _localFallback.getCardById(id);
    }
  }

  @override
  Future<void> saveCard(UserCard card) async {
    await _localFallback.saveCard(card);
    if (_useRemote) {
      try {
        await _remoteDataSource.saveCard(_getUserId(), UserCardDto.fromDomain(card));
      } catch (e) {
        // En Firestore offline, esto queda en cola de sync automáticamente
      }
    }
  }

  @override
  Future<void> deleteCard(String id) async {
    await _localFallback.deleteCard(id);
    if (_useRemote) {
      try {
        await _remoteDataSource.deleteCard(_getUserId(), id);
      } catch (_) {}
    }
  }

  @override
  Future<void> resetToDemoData() async {
    await _localFallback.resetToDemoData();
    if (_useRemote) {
      try {
        final cards = await _localFallback.getCards();
        await _remoteDataSource.clearAllCards(_getUserId());
        for (final c in cards) {
          await _remoteDataSource.saveCard(_getUserId(), UserCardDto.fromDomain(c));
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> clearAllCards() async {
    await _localFallback.clearAllCards();
    if (_useRemote) {
      try {
        await _remoteDataSource.clearAllCards(_getUserId());
      } catch (_) {}
    }
  }
}
