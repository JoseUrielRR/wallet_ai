import '../../../../core/utils/date_parser.dart';
import '../../domain/models/purchase.dart';

class PurchaseDto {
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
  final String status;
  final DateTime createdAt;

  const PurchaseDto({
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

  Purchase toDomain() {
    return Purchase(
      id: id,
      userId: userId,
      cardId: cardId,
      cardAlias: cardAlias,
      amountCents: amountCents,
      currency: currency,
      category: category,
      description: description,
      merchant: merchant,
      purchaseDate: purchaseDate,
      billingCycleId: billingCycleId,
      estimatedRewardCents: estimatedRewardCents,
      status: status,
      createdAt: createdAt,
    );
  }

  factory PurchaseDto.fromDomain(Purchase domain) {
    return PurchaseDto(
      id: domain.id,
      userId: domain.userId,
      cardId: domain.cardId,
      cardAlias: domain.cardAlias,
      amountCents: domain.amountCents,
      currency: domain.currency,
      category: domain.category,
      description: domain.description,
      merchant: domain.merchant,
      purchaseDate: domain.purchaseDate,
      billingCycleId: domain.billingCycleId,
      estimatedRewardCents: domain.estimatedRewardCents,
      status: domain.status,
      createdAt: domain.createdAt,
    );
  }

  Map<String, dynamic> toFirestore() {
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

  factory PurchaseDto.fromFirestore(Map<String, dynamic> map, [String? docId]) {
    final now = DateTime.now();
    return PurchaseDto(
      id: docId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      cardId: map['cardId']?.toString() ?? '',
      cardAlias: map['cardAlias']?.toString() ?? '',
      amountCents: (map['amountCents'] as num?)?.toInt() ?? 0,
      currency: map['currency']?.toString() ?? 'MXN',
      category: map['category']?.toString() ?? 'all',
      description: map['description']?.toString() ?? '',
      merchant: map['merchant']?.toString() ?? '',
      purchaseDate: DateParser.parseWithFallback(map['purchaseDate'], now),
      billingCycleId: map['billingCycleId']?.toString() ?? '',
      estimatedRewardCents: (map['estimatedRewardCents'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'recorded',
      createdAt: DateParser.parseWithFallback(map['createdAt'], now),
    );
  }
}
