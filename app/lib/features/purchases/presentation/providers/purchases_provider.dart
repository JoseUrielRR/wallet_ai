import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/purchase_repository_impl.dart';
import '../../domain/models/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';

final purchaseRepositoryProvider = Provider<IPurchaseRepository>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return PurchaseRepositoryImpl(getUserId: () => userId);
});

final purchasesStreamProvider = StreamProvider<List<Purchase>>((ref) {
  final repo = ref.watch(purchaseRepositoryProvider);
  return repo.watchPurchases();
});

class PurchasesNotifier extends Notifier<AsyncValue<List<Purchase>>> {
  IPurchaseRepository get _repository => ref.read(purchaseRepositoryProvider);

  @override
  AsyncValue<List<Purchase>> build() {
    _loadPurchases();
    return const AsyncValue.loading();
  }

  Future<void> _loadPurchases() async {
    try {
      final purchases = await _repository.getPurchases();
      if (!ref.mounted) return;
      state = AsyncValue.data(purchases);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> savePurchase(Purchase purchase) async {
    await _repository.savePurchase(purchase);
    await _loadPurchases();
  }

  Future<void> deletePurchase(String id) async {
    await _repository.deletePurchase(id);
    await _loadPurchases();
  }

  Future<void> resetToDemo() async {
    await _repository.resetToDemoPurchases();
    await _loadPurchases();
  }
}

final purchasesProvider =
    NotifierProvider<PurchasesNotifier, AsyncValue<List<Purchase>>>(
  PurchasesNotifier.new,
);
