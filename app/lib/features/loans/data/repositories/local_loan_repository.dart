import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/loan.dart';
import '../../domain/repositories/loan_repository.dart';

class LocalLoanRepository implements ILoanRepository {
  static const String _storageKey = 'wallet_ai_user_loans_v1';
  final _loansStreamController = StreamController<List<Loan>>.broadcast();
  List<Loan> _cachedLoans = [];
  bool _initialized = false;

  static List<Loan> get _initialDemoLoans => [
        Loan(
          id: 'loan_demo_personal',
          userId: 'usr_demo',
          name: 'Préstamo Nómina Aurora (Demo)',
          lender: 'Banco Aurora',
          originalAmountCents: 5000000, // $50,000.00
          outstandingBalanceCents: 3200000, // $32,000.00
          interestRateAnnual: 18.5,
          paymentAmountCents: 245000, // $2,450.00
          paymentFrequency: 'monthly',
          nextPaymentDate: DateTime.now().add(const Duration(days: 12)),
          status: 'active',
          notes: 'Cuota fija mensual descontada automáticamente.',
          createdAt: DateTime(2026, 1, 15),
          updatedAt: DateTime(2026, 8, 15),
        ),
      ];

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _cachedLoans = decoded
            .map((item) => Loan.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        _cachedLoans = [];
        await _saveToDisk();
      }
    } catch (_) {
      _cachedLoans = [];
    }
    _initialized = true;
    _loansStreamController.add(_cachedLoans);
  }

  Future<void> _saveToDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedLoans.map((l) => l.toMap()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {
      // Ignorar en tests puros
    }
  }

  @override
  Future<List<Loan>> getLoans() async {
    await _ensureInitialized();
    return List.unmodifiable(_cachedLoans);
  }

  @override
  Stream<List<Loan>> watchLoans() {
    _ensureInitialized();
    if (_initialized) {
      Timer.run(() => _loansStreamController.add(List.unmodifiable(_cachedLoans)));
    }
    return _loansStreamController.stream;
  }

  @override
  Future<void> saveLoan(Loan loan) async {
    await _ensureInitialized();
    final index = _cachedLoans.indexWhere((l) => l.id == loan.id);
    if (index >= 0) {
      _cachedLoans[index] = loan.copyWith(updatedAt: DateTime.now());
    } else {
      _cachedLoans.add(loan);
    }
    await _saveToDisk();
    _loansStreamController.add(List.unmodifiable(_cachedLoans));
  }

  @override
  Future<void> deleteLoan(String id) async {
    await _ensureInitialized();
    _cachedLoans.removeWhere((l) => l.id == id);
    await _saveToDisk();
    _loansStreamController.add(List.unmodifiable(_cachedLoans));
  }

  @override
  Future<void> recordPayment(String loanId, int paymentAmountCents) async {
    await _ensureInitialized();
    final index = _cachedLoans.indexWhere((l) => l.id == loanId);
    if (index >= 0) {
      final loan = _cachedLoans[index];
      final newBalance = loan.outstandingBalanceCents - paymentAmountCents;
      final effectiveBalance = newBalance < 0 ? 0 : newBalance;
      final newStatus = effectiveBalance == 0 ? 'paid_off' : loan.status;

      _cachedLoans[index] = loan.copyWith(
        outstandingBalanceCents: effectiveBalance,
        status: newStatus,
        nextPaymentDate: loan.nextPaymentDate.add(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      );
      await _saveToDisk();
      _loansStreamController.add(List.unmodifiable(_cachedLoans));
    }
  }

  @override
  Future<void> resetToDemoLoans() async {
    _cachedLoans = List.from(_initialDemoLoans);
    await _saveToDisk();
    _loansStreamController.add(List.unmodifiable(_cachedLoans));
  }
}
