import 'benefit.dart';

class UserCard {
  final String id;
  final String userId;
  final String issuerId;
  final String issuerName;
  final String? productId;
  final String productName;
  final String alias;
  final String type; // 'credit', 'debit'
  final String last4;
  final String currency;
  final int creditLimitCents;
  final int currentBalanceCents;
  final int availableCreditCents;
  final int statementClosingDay; // 1 a 31
  final int paymentDueDay; // 1 a 31
  final int daysBetweenCutoffAndDue; // ej. 20 días tras corte
  final bool adjustForHolidays;
  final String colorHex;
  final String status; // 'active', 'paused', 'archived'
  final List<Benefit> benefits;
  final String notes;
  final DateTime? confirmedClosingDate;
  final DateTime? confirmedPaymentDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserCard({
    required this.id,
    required this.userId,
    required this.issuerId,
    required this.issuerName,
    this.productId,
    required this.productName,
    required this.alias,
    required this.type,
    this.last4 = '',
    this.currency = 'MXN',
    required this.creditLimitCents,
    required this.currentBalanceCents,
    required this.availableCreditCents,
    required this.statementClosingDay,
    required this.paymentDueDay,
    this.daysBetweenCutoffAndDue = 20,
    this.adjustForHolidays = true,
    this.colorHex = '#388BFD',
    this.status = 'active',
    this.benefits = const [],
    this.notes = '',
    this.confirmedClosingDate,
    this.confirmedPaymentDueDate,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCredit => type == 'credit';
  bool get isDebit => type == 'debit';
  bool get isActive => status == 'active';

  double get creditUtilizationRatio {
    if (!isCredit || creditLimitCents <= 0) return 0.0;
    return currentBalanceCents / creditLimitCents;
  }

  int get calculatedAvailableCreditCents {
    if (!isCredit) return 0;
    final derived = creditLimitCents - currentBalanceCents;
    return derived < 0 ? 0 : derived;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'issuerId': issuerId,
      'issuerName': issuerName,
      'productId': productId,
      'productName': productName,
      'alias': alias,
      'type': type,
      'last4': last4,
      'currency': currency,
      'creditLimitCents': creditLimitCents,
      'currentBalanceCents': currentBalanceCents,
      'availableCreditCents': availableCreditCents,
      'statementClosingDay': statementClosingDay,
      'paymentDueDay': paymentDueDay,
      'daysBetweenCutoffAndDue': daysBetweenCutoffAndDue,
      'adjustForHolidays': adjustForHolidays,
      'colorHex': colorHex,
      'status': status,
      'benefits': benefits.map((b) => b.toMap()).toList(),
      'notes': notes,
      'confirmedClosingDate': confirmedClosingDate?.toIso8601String(),
      'confirmedPaymentDueDate': confirmedPaymentDueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserCard.fromMap(Map<String, dynamic> map) {
    return UserCard(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      issuerId: map['issuerId'] ?? '',
      issuerName: map['issuerName'] ?? '',
      productId: map['productId'],
      productName: map['productName'] ?? '',
      alias: map['alias'] ?? '',
      type: map['type'] ?? 'credit',
      last4: map['last4'] ?? '',
      currency: map['currency'] ?? 'MXN',
      creditLimitCents: map['creditLimitCents'] ?? 0,
      currentBalanceCents: map['currentBalanceCents'] ?? 0,
      availableCreditCents: map['availableCreditCents'] ?? 0,
      statementClosingDay: map['statementClosingDay'] ?? 15,
      paymentDueDay: map['paymentDueDay'] ?? 5,
      daysBetweenCutoffAndDue: map['daysBetweenCutoffAndDue'] ?? 20,
      adjustForHolidays: map['adjustForHolidays'] ?? true,
      colorHex: map['colorHex'] ?? '#388BFD',
      status: map['status'] ?? 'active',
      benefits: (map['benefits'] as List<dynamic>?)
              ?.map((item) => Benefit.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      notes: map['notes'] ?? '',
      confirmedClosingDate: map['confirmedClosingDate'] != null
          ? DateTime.tryParse(map['confirmedClosingDate'])
          : null,
      confirmedPaymentDueDate: map['confirmedPaymentDueDate'] != null
          ? DateTime.tryParse(map['confirmedPaymentDueDate'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  UserCard copyWith({
    String? id,
    String? userId,
    String? issuerId,
    String? issuerName,
    String? productId,
    String? productName,
    String? alias,
    String? type,
    String? last4,
    String? currency,
    int? creditLimitCents,
    int? currentBalanceCents,
    int? availableCreditCents,
    int? statementClosingDay,
    int? paymentDueDay,
    int? daysBetweenCutoffAndDue,
    bool? adjustForHolidays,
    String? colorHex,
    String? status,
    List<Benefit>? benefits,
    String? notes,
    DateTime? confirmedClosingDate,
    DateTime? confirmedPaymentDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      issuerId: issuerId ?? this.issuerId,
      issuerName: issuerName ?? this.issuerName,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      alias: alias ?? this.alias,
      type: type ?? this.type,
      last4: last4 ?? this.last4,
      currency: currency ?? this.currency,
      creditLimitCents: creditLimitCents ?? this.creditLimitCents,
      currentBalanceCents: currentBalanceCents ?? this.currentBalanceCents,
      availableCreditCents: availableCreditCents ?? this.availableCreditCents,
      statementClosingDay: statementClosingDay ?? this.statementClosingDay,
      paymentDueDay: paymentDueDay ?? this.paymentDueDay,
      daysBetweenCutoffAndDue:
          daysBetweenCutoffAndDue ?? this.daysBetweenCutoffAndDue,
      adjustForHolidays: adjustForHolidays ?? this.adjustForHolidays,
      colorHex: colorHex ?? this.colorHex,
      status: status ?? this.status,
      benefits: benefits ?? this.benefits,
      notes: notes ?? this.notes,
      confirmedClosingDate: confirmedClosingDate ?? this.confirmedClosingDate,
      confirmedPaymentDueDate:
          confirmedPaymentDueDate ?? this.confirmedPaymentDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
