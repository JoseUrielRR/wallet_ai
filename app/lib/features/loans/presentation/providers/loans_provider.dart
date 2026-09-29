import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/loan.dart';
import '../../domain/repositories/loan_repository.dart';
import '../../data/repositories/local_loan_repository.dart';

final loanRepositoryProvider = Provider<ILoanRepository>((ref) {
  return LocalLoanRepository();
});

class LoansNotifier extends Notifier<AsyncValue<List<Loan>>> {
  late final ILoanRepository _repository;

  @override
  AsyncValue<List<Loan>> build() {
    _repository = ref.watch(loanRepositoryProvider);
    _loadLoans();
    return const AsyncValue.loading();
  }

  Future<void> _loadLoans() async {
    try {
      final loans = await _repository.getLoans();
      state = AsyncValue.data(loans);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveLoan(Loan loan) async {
    await _repository.saveLoan(loan);
    await _loadLoans();
  }

  Future<void> deleteLoan(String id) async {
    await _repository.deleteLoan(id);
    await _loadLoans();
  }

  Future<void> recordPayment(String id, int amountCents) async {
    await _repository.recordPayment(id, amountCents);
    await _loadLoans();
  }

  Future<void> resetToDemo() async {
    await _repository.resetToDemoLoans();
    await _loadLoans();
  }
}

final loansProvider = NotifierProvider<LoansNotifier, AsyncValue<List<Loan>>>(LoansNotifier.new);
