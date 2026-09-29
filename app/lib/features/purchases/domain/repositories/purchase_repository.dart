import '../models/purchase.dart';

abstract class IPurchaseRepository {
  Future<List<Purchase>> getPurchases();
  Stream<List<Purchase>> watchPurchases();
  Future<void> savePurchase(Purchase purchase);
  Future<void> deletePurchase(String id);
  Future<void> resetToDemoPurchases();
  Future<void> clearAllPurchases();
}
