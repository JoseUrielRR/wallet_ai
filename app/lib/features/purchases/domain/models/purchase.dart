class Purchase {
  final String id;
  final String userId;
  final String cardId;
  final String cardAlias;
  final int amountCents;
  final String currency;
  final String category;
  final String description;
  final String merchant;
  final DateTime purchaseDate;
  final String billingCycleId;
  final int estimatedRewardCents;
  final String status; // 'recorded', 'settled'
  final DateTime createdAt;

  const Purchase({
    required this.id,
    required this.userId,
    required this.cardId,
    required this.cardAlias,
    required this.amountCents,
    this.currency = 'MXN',
    required this.category,
    this.description = '',
    this.merchant = '',
    required this.purchaseDate,
    required this.billingCycleId,
    this.estimatedRewardCents = 0,
    this.status = 'recorded',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cardId': cardId,
      'cardAlias': cardAlias,
      'amountCents': amountCents,
      'currency': currency,
      'category': category,
      'description': description,
      'merchant': merchant,
      'purchaseDate': purchaseDate.toIso8601String(),
      'billingCycleId': billingCycleId,
      'estimatedRewardCents': estimatedRewardCents,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Purchase.fromMap(Map<String, dynamic> map) {
    return Purchase(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      cardId: map['cardId'] ?? '',
      cardAlias: map['cardAlias'] ?? '',
      amountCents: map['amountCents'] ?? 0,
      currency: map['currency'] ?? 'MXN',
      category: map['category'] ?? 'other',
      description: map['description'] ?? '',
      merchant: map['merchant'] ?? '',
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'])
          : DateTime.now(),
      billingCycleId: map['billingCycleId'] ?? '',
      estimatedRewardCents: map['estimatedRewardCents'] ?? 0,
      status: map['status'] ?? 'recorded',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Purchase copyWith({
    String? id,
    String? userId,
    String? cardId,
    String? cardAlias,
    int? amountCents,
    String? currency,
    String? category,
    String? description,
    String? merchant,
    DateTime? purchaseDate,
    String? billingCycleId,
    int? estimatedRewardCents,
    String? status,
    DateTime? createdAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      cardId: cardId ?? this.cardId,
      cardAlias: cardAlias ?? this.cardAlias,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      merchant: merchant ?? this.merchant,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      billingCycleId: billingCycleId ?? this.billingCycleId,
      estimatedRewardCents: estimatedRewardCents ?? this.estimatedRewardCents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
