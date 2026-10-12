import '../../../../core/utils/date_parser.dart';
import '../../domain/models/loan.dart';

class LoanDto {
  final String id;
  final String userId;
  final String name;
  final String lender;
  final int originalAmountCents;
  final int outstandingBalanceCents;
  final double interestRateAnnual;
  final int paymentAmountCents;
  final String paymentFrequency;
  final DateTime nextPaymentDate;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LoanDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.lender,
    required this.originalAmountCents,
    required this.outstandingBalanceCents,
    this.interestRateAnnual = 0.0,
    required this.paymentAmountCents,
    this.paymentFrequency = 'monthly',
    required this.nextPaymentDate,
    this.status = 'active',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Loan toDomain() {
    return Loan(
      id: id,
      userId: userId,
      name: name,
      lender: lender,
      originalAmountCents: originalAmountCents,
      outstandingBalanceCents: outstandingBalanceCents,
      interestRateAnnual: interestRateAnnual,
      paymentAmountCents: paymentAmountCents,
      paymentFrequency: paymentFrequency,
      nextPaymentDate: nextPaymentDate,
      status: status,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory LoanDto.fromDomain(Loan domain) {
    return LoanDto(
      id: domain.id,
      userId: domain.userId,
      name: domain.name,
      lender: domain.lender,
      originalAmountCents: domain.originalAmountCents,
      outstandingBalanceCents: domain.outstandingBalanceCents,
      interestRateAnnual: domain.interestRateAnnual,
      paymentAmountCents: domain.paymentAmountCents,
      paymentFrequency: domain.paymentFrequency,
      nextPaymentDate: domain.nextPaymentDate,
      status: domain.status,
      notes: domain.notes,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'lender': lender,
      'originalAmountCents': originalAmountCents,
      'outstandingBalanceCents': outstandingBalanceCents,
      'interestRateAnnual': interestRateAnnual,
      'paymentAmountCents': paymentAmountCents,
      'paymentFrequency': paymentFrequency,
      'nextPaymentDate': nextPaymentDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LoanDto.fromFirestore(Map<String, dynamic> map, [String? docId]) {
    final now = DateTime.now();
    return LoanDto(
      id: docId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      lender: map['lender']?.toString() ?? '',
      originalAmountCents: (map['originalAmountCents'] as num?)?.toInt() ?? 0,
      outstandingBalanceCents: (map['outstandingBalanceCents'] as num?)?.toInt() ?? 0,
      interestRateAnnual: (map['interestRateAnnual'] as num?)?.toDouble() ?? 0.0,
      paymentAmountCents: (map['paymentAmountCents'] as num?)?.toInt() ?? 0,
      paymentFrequency: map['paymentFrequency']?.toString() ?? 'monthly',
      nextPaymentDate: DateParser.parseWithFallback(map['nextPaymentDate'], now),
      status: map['status']?.toString() ?? 'active',
      notes: map['notes']?.toString() ?? '',
      createdAt: DateParser.parseWithFallback(map['createdAt'], now),
      updatedAt: DateParser.parseWithFallback(map['updatedAt'], now),
    );
  }
}
