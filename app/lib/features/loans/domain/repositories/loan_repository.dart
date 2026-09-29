import '../models/loan.dart';

abstract class ILoanRepository {
  Future<List<Loan>> getLoans();
  Stream<List<Loan>> watchLoans();
  Future<void> saveLoan(Loan loan);
  Future<void> deleteLoan(String id);
  Future<void> recordPayment(String loanId, int paymentAmountCents);
  Future<void> resetToDemoLoans();
}
