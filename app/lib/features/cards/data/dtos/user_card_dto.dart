import '../../../../core/utils/date_parser.dart';
import '../../domain/models/user_card.dart';
import 'benefit_dto.dart';

class UserCardDto {
  final String id;
  final String userId;
  final String issuerId;
  final String issuerName;
  final String? productId;
  final String productName;
  final String alias;
  final String type;
  final String last4;
  final String currency;
  final int creditLimitCents;
  final int currentBalanceCents;
  final int availableCreditCents;
  final int statementClosingDay;
  final int paymentDueDay;
  final int daysBetweenCutoffAndDue;
  final bool adjustForHolidays;
  final String colorHex;
  final String status;
  final List<BenefitDto> benefits;
  final String notes;
  final DateTime? confirmedClosingDate;
  final DateTime? confirmedPaymentDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserCardDto({
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

  UserCard toDomain() {
    return UserCard(
      id: id,
      userId: userId,
      issuerId: issuerId,
      issuerName: issuerName,
      productId: productId,
      productName: productName,
      alias: alias,
      type: type,
      last4: last4,
      currency: currency,
      creditLimitCents: creditLimitCents,
      currentBalanceCents: currentBalanceCents,
      availableCreditCents: availableCreditCents,
      statementClosingDay: statementClosingDay,
      paymentDueDay: paymentDueDay,
      daysBetweenCutoffAndDue: daysBetweenCutoffAndDue,
      adjustForHolidays: adjustForHolidays,
      colorHex: colorHex,
      status: status,
      benefits: benefits.map((b) => b.toDomain()).toList(),
      notes: notes,
      confirmedClosingDate: confirmedClosingDate,
      confirmedPaymentDueDate: confirmedPaymentDueDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory UserCardDto.fromDomain(UserCard domain) {
    return UserCardDto(
      id: domain.id,
      userId: domain.userId,
      issuerId: domain.issuerId,
      issuerName: domain.issuerName,
      productId: domain.productId,
      productName: domain.productName,
      alias: domain.alias,
      type: domain.type,
      last4: domain.last4,
      currency: domain.currency,
      creditLimitCents: domain.creditLimitCents,
      currentBalanceCents: domain.currentBalanceCents,
      availableCreditCents: domain.availableCreditCents,
      statementClosingDay: domain.statementClosingDay,
      paymentDueDay: domain.paymentDueDay,
      daysBetweenCutoffAndDue: domain.daysBetweenCutoffAndDue,
      adjustForHolidays: domain.adjustForHolidays,
      colorHex: domain.colorHex,
      status: domain.status,
      benefits: domain.benefits.map((b) => BenefitDto.fromDomain(b)).toList(),
      notes: domain.notes,
      confirmedClosingDate: domain.confirmedClosingDate,
      confirmedPaymentDueDate: domain.confirmedPaymentDueDate,
      createdAt: domain.createdAt,
      updatedAt: domain.updatedAt,
    );
  }

  Map<String, dynamic> toFirestore() {
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
      'benefits': benefits.map((b) => b.toFirestore()).toList(),
      'notes': notes,
      'confirmedClosingDate': confirmedClosingDate?.toIso8601String(),
      'confirmedPaymentDueDate': confirmedPaymentDueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserCardDto.fromFirestore(Map<String, dynamic> map, [String? docId]) {
    final rawBenefits = map['benefits'];
    final parsedBenefits = <BenefitDto>[];
    if (rawBenefits is List) {
      for (final item in rawBenefits) {
        if (item is Map<String, dynamic>) {
          parsedBenefits.add(BenefitDto.fromFirestore(item));
        }
      }
    }

    final now = DateTime.now();
    return UserCardDto(
      id: docId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      issuerId: map['issuerId']?.toString() ?? '',
      issuerName: map['issuerName']?.toString() ?? '',
      productId: map['productId']?.toString(),
      productName: map['productName']?.toString() ?? '',
      alias: map['alias']?.toString() ?? '',
      type: map['type']?.toString() ?? 'credit',
      last4: map['last4']?.toString() ?? '',
      currency: map['currency']?.toString() ?? 'MXN',
      creditLimitCents: (map['creditLimitCents'] as num?)?.toInt() ?? 0,
      currentBalanceCents: (map['currentBalanceCents'] as num?)?.toInt() ?? 0,
      availableCreditCents: (map['availableCreditCents'] as num?)?.toInt() ?? 0,
      statementClosingDay: (map['statementClosingDay'] as num?)?.toInt() ?? 15,
      paymentDueDay: (map['paymentDueDay'] as num?)?.toInt() ?? 5,
      daysBetweenCutoffAndDue: (map['daysBetweenCutoffAndDue'] as num?)?.toInt() ?? 20,
      adjustForHolidays: map['adjustForHolidays'] == true,
      colorHex: map['colorHex']?.toString() ?? '#388BFD',
      status: map['status']?.toString() ?? 'active',
      benefits: parsedBenefits,
      notes: map['notes']?.toString() ?? '',
      confirmedClosingDate: DateParser.parse(map['confirmedClosingDate']),
      confirmedPaymentDueDate: DateParser.parse(map['confirmedPaymentDueDate']),
      createdAt: DateParser.parseWithFallback(map['createdAt'], now),
      updatedAt: DateParser.parseWithFallback(map['updatedAt'], now),
    );
  }
}
