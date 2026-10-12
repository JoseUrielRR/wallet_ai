import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/firebase/firestore_collections.dart';
import '../dtos/loan_dto.dart';

abstract class ILoanRemoteDataSource {
  Stream<List<LoanDto>> watchLoans(String userId);
  Future<List<LoanDto>> getLoans(String userId);
  Future<void> saveLoan(String userId, LoanDto loan);
  Future<void> deleteLoan(String userId, String loanId);
  Future<void> clearAllLoans(String userId);
}

class FirestoreLoanRemoteDataSource implements ILoanRemoteDataSource {
  final FirebaseFirestore? _firestore;

  FirestoreLoanRemoteDataSource([this._firestore]);

  FirebaseFirestore get _instance => _firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _instance.collection(FirestoreCollections.loans(userId));
  }

  @override
  Stream<List<LoanDto>> watchLoans(String userId) {
    try {
      return _collection(userId).snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return LoanDto.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw ServerException('Error al escuchar préstamos de Firestore: $e');
    }
  }

  @override
  Future<List<LoanDto>> getLoans(String userId) async {
    try {
      final snapshot = await _collection(userId).get();
      return snapshot.docs.map((doc) {
        return LoanDto.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw ServerException('Error al obtener préstamos de Firestore: $e');
    }
  }

  @override
  Future<void> saveLoan(String userId, LoanDto loan) async {
    try {
      await _collection(userId)
          .doc(loan.id)
          .set(loan.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerException('Error al guardar préstamo en Firestore: $e');
    }
  }

  @override
  Future<void> deleteLoan(String userId, String loanId) async {
    try {
      await _collection(userId).doc(loanId).delete();
    } catch (e) {
      throw ServerException('Error al eliminar préstamo de Firestore: $e');
    }
  }

  @override
  Future<void> clearAllLoans(String userId) async {
    try {
      final snapshot = await _collection(userId).get();
      final batch = _instance.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('Error al limpiar préstamos de Firestore: $e');
    }
  }
}
