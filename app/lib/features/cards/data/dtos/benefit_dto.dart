import '../../../../core/utils/date_parser.dart';
import '../../domain/models/benefit.dart';

class BenefitDto {
  final String id;
  final String category;
  final String rewardType;
  final double rewardRate;
  final int rewardCapCents;
  final int minimumSpendCents;
  final DateTime? startDate;
  final DateTime? endDate;
  final String terms;
  final String verificationStatus;

  const BenefitDto({
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

  Benefit toDomain() {
    return Benefit(
      id: id,
      category: category,
      rewardType: rewardType,
      rewardRate: rewardRate,
      rewardCapCents: rewardCapCents,
      minimumSpendCents: minimumSpendCents,
      startDate: startDate,
      endDate: endDate,
      terms: terms,
      verificationStatus: verificationStatus,
    );
  }

  factory BenefitDto.fromDomain(Benefit domain) {
    return BenefitDto(
      id: domain.id,
      category: domain.category,
      rewardType: domain.rewardType,
      rewardRate: domain.rewardRate,
      rewardCapCents: domain.rewardCapCents,
      minimumSpendCents: domain.minimumSpendCents,
      startDate: domain.startDate,
      endDate: domain.endDate,
      terms: domain.terms,
      verificationStatus: domain.verificationStatus,
    );
  }

  Map<String, dynamic> toFirestore() {
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

  factory BenefitDto.fromFirestore(Map<String, dynamic> map, [String? docId]) {
    return BenefitDto(
      id: docId ?? map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? 'all',
      rewardType: map['rewardType']?.toString() ?? 'cashback',
      rewardRate: (map['rewardRate'] as num?)?.toDouble() ?? 0.0,
      rewardCapCents: (map['rewardCapCents'] as num?)?.toInt() ?? 0,
      minimumSpendCents: (map['minimumSpendCents'] as num?)?.toInt() ?? 0,
      startDate: DateParser.parse(map['startDate']),
      endDate: DateParser.parse(map['endDate']),
      terms: map['terms']?.toString() ?? '',
      verificationStatus: map['verificationStatus']?.toString() ?? 'confirmed',
    );
  }
}
