import '../../../../core/firebase/firebase_service.dart';
import '../../domain/models/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../datasources/purchase_remote_datasource.dart';
import '../dtos/purchase_dto.dart';
import 'local_purchase_repository.dart';

class PurchaseRepositoryImpl implements IPurchaseRepository {
  final IPurchaseRemoteDataSource _remoteDataSource;
  final LocalPurchaseRepository _localFallback;
  final String Function() _getUserId;

  PurchaseRepositoryImpl({
    IPurchaseRemoteDataSource? remoteDataSource,
    LocalPurchaseRepository? localFallback,
    String Function()? getUserId,
  })  : _remoteDataSource = remoteDataSource ?? FirestorePurchaseRemoteDataSource(),
        _localFallback = localFallback ?? LocalPurchaseRepository(),
        _getUserId = getUserId ?? (() => 'demo_user');

  bool get _useRemote => FirebaseService.isInitialized;

  @override
  Future<List<Purchase>> getPurchases() async {
    if (!_useRemote) {
      return _localFallback.getPurchases();
    }
    try {
      final dtos = await _remoteDataSource.getPurchases(_getUserId());
      return dtos.map((d) => d.toDomain()).toList();
    } catch (_) {
      return _localFallback.getPurchases();
    }
  }

  @override
  Stream<List<Purchase>> watchPurchases() {
    if (!_useRemote) {
      return _localFallback.watchPurchases();
    }
    try {
      return _remoteDataSource.watchPurchases(_getUserId()).map((dtos) {
        return dtos.map((d) => d.toDomain()).toList();
      }).handleError((_) {
        return _localFallback.watchPurchases();
      });
    } catch (_) {
      return _localFallback.watchPurchases();
    }
  }

  @override
  Future<void> savePurchase(Purchase purchase) async {
    await _localFallback.savePurchase(purchase);
    if (_useRemote) {
      try {
        await _remoteDataSource.savePurchase(_getUserId(), PurchaseDto.fromDomain(purchase));
      } catch (_) {}
    }
  }

  @override
  Future<void> deletePurchase(String id) async {
    await _localFallback.deletePurchase(id);
    if (_useRemote) {
      try {
        await _remoteDataSource.deletePurchase(_getUserId(), id);
      } catch (_) {}
    }
  }

  @override
  Future<void> resetToDemoPurchases() async {
    await _localFallback.resetToDemoPurchases();
    if (_useRemote) {
      try {
        final list = await _localFallback.getPurchases();
        await _remoteDataSource.clearAllPurchases(_getUserId());
        for (final p in list) {
          await _remoteDataSource.savePurchase(_getUserId(), PurchaseDto.fromDomain(p));
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> clearAllPurchases() async {
    await _localFallback.clearAllPurchases();
    if (_useRemote) {
      try {
        await _remoteDataSource.clearAllPurchases(_getUserId());
      } catch (_) {}
    }
  }
}
