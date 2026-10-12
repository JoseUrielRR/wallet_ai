import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/loan_repository_impl.dart';
import '../../domain/models/loan.dart';
import '../../domain/repositories/loan_repository.dart';

final loanRepositoryProvider = Provider<ILoanRepository>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return LoanRepositoryImpl(getUserId: () => userId);
});

final loansStreamProvider = StreamProvider<List<Loan>>((ref) {
  final repo = ref.watch(loanRepositoryProvider);
  return repo.watchLoans();
});

class LoansNotifier extends Notifier<AsyncValue<List<Loan>>> {
  ILoanRepository get _repository => ref.read(loanRepositoryProvider);

  @override
  AsyncValue<List<Loan>> build() {
    _loadLoans();
    return const AsyncValue.loading();
  }

  Future<void> _loadLoans() async {
    try {
      final loans = await _repository.getLoans();
      if (!ref.mounted) return;
      state = AsyncValue.data(loans);
    } catch (e, st) {
      if (!ref.mounted) return;
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

final loansProvider =
    NotifierProvider<LoansNotifier, AsyncValue<List<Loan>>>(LoansNotifier.new);
