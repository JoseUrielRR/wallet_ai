import '../../../../core/firebase/firebase_service.dart';
import '../../domain/models/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../datasources/loan_remote_datasource.dart';
import '../dtos/loan_dto.dart';
import 'local_loan_repository.dart';

class LoanRepositoryImpl implements ILoanRepository {
  final ILoanRemoteDataSource _remoteDataSource;
  final LocalLoanRepository _localFallback;
  final String Function() _getUserId;

  LoanRepositoryImpl({
    ILoanRemoteDataSource? remoteDataSource,
    LocalLoanRepository? localFallback,
    String Function()? getUserId,
  })  : _remoteDataSource = remoteDataSource ?? FirestoreLoanRemoteDataSource(),
        _localFallback = localFallback ?? LocalLoanRepository(),
        _getUserId = getUserId ?? (() => 'demo_user');

  bool get _useRemote => FirebaseService.isInitialized;

  @override
  Future<List<Loan>> getLoans() async {
    if (!_useRemote) {
      return _localFallback.getLoans();
    }
    try {
      final dtos = await _remoteDataSource.getLoans(_getUserId());
      return dtos.map((d) => d.toDomain()).toList();
    } catch (_) {
      return _localFallback.getLoans();
    }
  }

  @override
  Stream<List<Loan>> watchLoans() {
    if (!_useRemote) {
      return _localFallback.watchLoans();
    }
    try {
      return _remoteDataSource.watchLoans(_getUserId()).map((dtos) {
        return dtos.map((d) => d.toDomain()).toList();
      }).handleError((_) {
        return _localFallback.watchLoans();
      });
    } catch (_) {
      return _localFallback.watchLoans();
    }
  }

  @override
  Future<void> saveLoan(Loan loan) async {
    await _localFallback.saveLoan(loan);
    if (_useRemote) {
      try {
        await _remoteDataSource.saveLoan(_getUserId(), LoanDto.fromDomain(loan));
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteLoan(String id) async {
    await _localFallback.deleteLoan(id);
    if (_useRemote) {
      try {
        await _remoteDataSource.deleteLoan(_getUserId(), id);
      } catch (_) {}
    }
  }

  @override
  Future<void> recordPayment(String loanId, int paymentAmountCents) async {
    await _localFallback.recordPayment(loanId, paymentAmountCents);
    if (_useRemote) {
      try {
        final loans = await getLoans();
        final loan = loans.firstWhere((l) => l.id == loanId);
        await _remoteDataSource.saveLoan(_getUserId(), LoanDto.fromDomain(loan));
      } catch (_) {}
    }
  }

  @override
  Future<void> resetToDemoLoans() async {
    await _localFallback.resetToDemoLoans();
    if (_useRemote) {
      try {
        final loans = await _localFallback.getLoans();
        await _remoteDataSource.clearAllLoans(_getUserId());
        for (final l in loans) {
          await _remoteDataSource.saveLoan(_getUserId(), LoanDto.fromDomain(l));
        }
      } catch (_) {}
    }
  }
}
