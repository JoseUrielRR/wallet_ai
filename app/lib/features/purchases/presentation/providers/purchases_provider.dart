import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../data/repositories/local_purchase_repository.dart';

final purchaseRepositoryProvider = Provider<IPurchaseRepository>((ref) {
  return LocalPurchaseRepository();
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

final purchasesProvider = NotifierProvider<PurchasesNotifier, AsyncValue<List<Purchase>>>(PurchasesNotifier.new);
