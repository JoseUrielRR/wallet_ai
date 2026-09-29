class Benefit {
  final String id;
  final String category; // 'supermarket', 'dining', 'fuel', 'travel', 'all', etc.
  final String rewardType; // 'cashback', 'points', 'miles', 'discount'
  final double rewardRate; // Porcentaje, ej. 3.0 para 3%
  final int rewardCapCents; // Tope máximo de recompensa en centavos (0 = sin tope)
  final int minimumSpendCents; // Gasto mínimo en centavos para aplicar
  final DateTime? startDate;
  final DateTime? endDate;
  final String terms;
  final String verificationStatus; // 'confirmed', 'estimated'

  const Benefit({
    required this.id,
    required this.category,
    required this.rewardType,
    required this.rewardRate,
    this.rewardCapCents = 0,
    this.minimumSpendCents = 0,
    this.startDate,
    this.endDate,
    this.terms = '',
    this.verificationStatus = 'confirmed',
  });

  bool isCurrentlyActive(DateTime targetDate) {
    if (startDate != null && targetDate.isBefore(startDate!)) {
      return false;
    }
    if (endDate != null && targetDate.isAfter(endDate!)) {
      return false;
    }
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'rewardType': rewardType,
      'rewardRate': rewardRate,
      'rewardCapCents': rewardCapCents,
      'minimumSpendCents': minimumSpendCents,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'terms': terms,
      'verificationStatus': verificationStatus,
    };
  }

  factory Benefit.fromMap(Map<String, dynamic> map) {
    return Benefit(
      id: map['id'] ?? '',
      category: map['category'] ?? 'all',
      rewardType: map['rewardType'] ?? 'cashback',
      rewardRate: (map['rewardRate'] as num?)?.toDouble() ?? 0.0,
      rewardCapCents: map['rewardCapCents'] ?? 0,
      minimumSpendCents: map['minimumSpendCents'] ?? 0,
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      terms: map['terms'] ?? '',
      verificationStatus: map['verificationStatus'] ?? 'confirmed',
    );
  }

  Benefit copyWith({
    String? id,
    String? category,
    String? rewardType,
    double? rewardRate,
    int? rewardCapCents,
    int? minimumSpendCents,
    DateTime? startDate,
    DateTime? endDate,
    String? terms,
    String? verificationStatus,
  }) {
    return Benefit(
      id: id ?? this.id,
      category: category ?? this.category,
      rewardType: rewardType ?? this.rewardType,
      rewardRate: rewardRate ?? this.rewardRate,
      rewardCapCents: rewardCapCents ?? this.rewardCapCents,
      minimumSpendCents: minimumSpendCents ?? this.minimumSpendCents,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      terms: terms ?? this.terms,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
