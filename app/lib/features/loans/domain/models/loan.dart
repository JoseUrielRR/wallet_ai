class Loan {
  final String id;
  final String userId;
  final String name;
  final String lender;
  final int originalAmountCents;
  final int outstandingBalanceCents;
  final double interestRateAnnual;
  final int paymentAmountCents;
  final String paymentFrequency; // 'monthly', 'biweekly', 'weekly'
  final DateTime nextPaymentDate;
  final String status; // 'active', 'paid_off'
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Loan({
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

  bool get isActive => status == 'active';

  double get progressPercentage {
    if (originalAmountCents <= 0) return 0.0;
    final paid = originalAmountCents - outstandingBalanceCents;
    return (paid / originalAmountCents).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
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

  factory Loan.fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      lender: map['lender'] ?? '',
      originalAmountCents: map['originalAmountCents'] ?? 0,
      outstandingBalanceCents: map['outstandingBalanceCents'] ?? 0,
      interestRateAnnual: (map['interestRateAnnual'] as num?)?.toDouble() ?? 0.0,
      paymentAmountCents: map['paymentAmountCents'] ?? 0,
      paymentFrequency: map['paymentFrequency'] ?? 'monthly',
      nextPaymentDate: map['nextPaymentDate'] != null
          ? DateTime.parse(map['nextPaymentDate'])
          : DateTime.now().add(const Duration(days: 15)),
      status: map['status'] ?? 'active',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  Loan copyWith({
    String? id,
    String? userId,
    String? name,
    String? lender,
    int? originalAmountCents,
    int? outstandingBalanceCents,
    double? interestRateAnnual,
    int? paymentAmountCents,
    String? paymentFrequency,
    DateTime? nextPaymentDate,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Loan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      lender: lender ?? this.lender,
      originalAmountCents: originalAmountCents ?? this.originalAmountCents,
      outstandingBalanceCents:
          outstandingBalanceCents ?? this.outstandingBalanceCents,
      interestRateAnnual: interestRateAnnual ?? this.interestRateAnnual,
      paymentAmountCents: paymentAmountCents ?? this.paymentAmountCents,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
