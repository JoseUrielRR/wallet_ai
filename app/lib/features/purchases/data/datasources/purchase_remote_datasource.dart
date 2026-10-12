import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../dtos/purchase_dto.dart';

abstract class IPurchaseRemoteDataSource {
  Stream<List<PurchaseDto>> watchPurchases(String userId);
  Future<List<PurchaseDto>> getPurchases(String userId);
  Future<void> savePurchase(String userId, PurchaseDto purchase);
  Future<void> deletePurchase(String userId, String purchaseId);
  Future<void> clearAllPurchases(String userId);
}

class FirestorePurchaseRemoteDataSource implements IPurchaseRemoteDataSource {
  final FirebaseFirestore? _firestore;

  FirestorePurchaseRemoteDataSource([this._firestore]);

  FirebaseFirestore get _instance => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _instance.collection(FirestoreCollections.purchases(userId));
  }

  @override
  Stream<List<PurchaseDto>> watchPurchases(String userId) {
    try {
      return _collection(userId)
          .orderBy('purchaseDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return PurchaseDto.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw ServerException('Error al escuchar compras de Firestore: $e');
    }
  }

  @override
  Future<List<PurchaseDto>> getPurchases(String userId) async {
    try {
      final snapshot = await _collection(userId)
          .orderBy('purchaseDate', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        return PurchaseDto.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw ServerException('Error al obtener compras de Firestore: $e');
    }
  }

  @override
  Future<void> savePurchase(String userId, PurchaseDto purchase) async {
    try {
      await _collection(userId)
          .doc(purchase.id)
          .set(purchase.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Error al guardar compra en Firestore: $e');
    }
  }

  @override
  Future<void> deletePurchase(String userId, String purchaseId) async {
    try {
      await _collection(userId).doc(purchaseId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar compra de Firestore: $e');
    }
  }

  @override
  Future<void> clearAllPurchases(String userId) async {
    try {
      final snapshot = await _collection(userId).get();
      final batch = _instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Error al limpiar compras de Firestore: $e');
    }
  }
}
