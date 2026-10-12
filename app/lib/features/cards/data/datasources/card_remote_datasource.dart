import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../dtos/user_card_dto.dart';

abstract class ICardRemoteDataSource {
  Stream<List<UserCardDto>> watchCards(String userId);
  Future<List<UserCardDto>> getCards(String userId);
  Future<UserCardDto?> getCardById(String userId, String cardId);
  Future<void> saveCard(String userId, UserCardDto card);
  Future<void> deleteCard(String userId, String cardId);
  Future<void> clearAllCards(String userId);
}

class FirestoreCardRemoteDataSource implements ICardRemoteDataSource {
  final FirebaseFirestore? _firestore;

  FirestoreCardRemoteDataSource([this._firestore]);

  FirebaseFirestore get _instance => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _instance.collection(FirestoreCollections.cards(userId));
  }

  @override
  Stream<List<UserCardDto>> watchCards(String userId) {
    try {
      return _collection(userId).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return UserCardDto.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw ServerException('Error al escuchar tarjetas de Firestore: $e');
    }
  }

  @override
  Future<List<UserCardDto>> getCards(String userId) async {
    try {
      final snapshot = await _collection(userId).get();
      return snapshot.docs.map((doc) {
        return UserCardDto.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw ServerException('Error al obtener tarjetas de Firestore: $e');
    }
  }

  @override
  Future<UserCardDto?> getCardById(String userId, String cardId) async {
    try {
      final doc = await _collection(userId).doc(cardId).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserCardDto.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Error al obtener tarjeta $cardId: $e');
    }
  }

  @override
  Future<void> saveCard(String userId, UserCardDto card) async {
    try {
      await _collection(userId)
          .doc(card.id)
          .set(card.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Error al guardar tarjeta en Firestore: $e');
    }
  }

  @override
  Future<void> deleteCard(String userId, String cardId) async {
    try {
      await _collection(userId).doc(cardId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar tarjeta de Firestore: $e');
    }
  }

  @override
  Future<void> clearAllCards(String userId) async {
    try {
      final snapshot = await _collection(userId).get();
      final batch = _instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Error al limpiar tarjetas en Firestore: $e');
    }
  }
}
