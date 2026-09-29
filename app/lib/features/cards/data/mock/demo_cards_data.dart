import '../../domain/models/benefit.dart';
import '../../domain/models/user_card.dart';

class DemoCardsData {
  DemoCardsData._();

  static List<UserCard> get initialDemoCards => [
        UserCard(
          id: 'card_demo_aurora',
          userId: 'usr_demo',
          issuerId: 'iss_aurora',
          issuerName: 'Banco Aurora (Demo)',
          productName: 'Aurora Black Rewards',
          alias: 'Aurora Black',
          type: 'credit',
          last4: '7412',
          currency: 'MXN',
          creditLimitCents: 6000000, // $60,000.00
          currentBalanceCents: 1250000, // $12,500.00
          availableCreditCents: 4750000, // $47,500.00
          statementClosingDay: 14,
          paymentDueDay: 4,
          daysBetweenCutoffAndDue: 20,
          adjustForHolidays: true,
          colorHex: '#8A05BE', // Morado elegante
          status: 'active',
          notes: 'Excelente para restaurantes y compras del supermercado.',
          benefits: [
            const Benefit(
              id: 'ben_aurora_super',
              category: 'supermarket',
              rewardType: 'cashback',
              rewardRate: 3.0,
              rewardCapCents: 50000,
              terms: 'Tope de \$500 MXN mensuales en compras de despensa.',
            ),
            const Benefit(
              id: 'ben_aurora_dining',
              category: 'dining',
              rewardType: 'cashback',
              rewardRate: 4.0,
              rewardCapCents: 60000,
              terms: 'Aplica en restaurantes y cafeterías participantes.',
            ),
            const Benefit(
              id: 'ben_aurora_all',
              category: 'all',
              rewardType: 'cashback',
              rewardRate: 1.0,
              terms: '1% en todas las compras sin excepción.',
            ),
          ],
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
        UserCard(
          id: 'card_demo_horizonte',
          userId: 'usr_demo',
          issuerId: 'iss_horizonte',
          issuerName: 'Banco Horizonte (Demo)',
          productName: 'Horizonte Travel Platinum',
          alias: 'Horizonte Viajes',
          type: 'credit',
          last4: '9834',
          currency: 'MXN',
          creditLimitCents: 9000000, // $90,000.00
          currentBalanceCents: 2100000, // $21,000.00
          availableCreditCents: 6900000, // $69,000.00
          statementClosingDay: 28,
          paymentDueDay: 18,
          daysBetweenCutoffAndDue: 20,
          adjustForHolidays: true,
          colorHex: '#004481', // Azul bancario profundo
          status: 'active',
          notes: 'Usar para gasolineras y boletos de avión.',
          benefits: [
            const Benefit(
              id: 'ben_horiz_travel',
              category: 'travel',
              rewardType: 'cashback',
              rewardRate: 5.0,
              rewardCapCents: 150000,
              minimumSpendCents: 100000, // Mínimo $1,000 MXN
              terms: '5% en vuelos y hoteles en compras mayores a \$1,000 MXN.',
            ),
            const Benefit(
              id: 'ben_horiz_fuel',
              category: 'fuel',
              rewardType: 'cashback',
              rewardRate: 2.5,
              rewardCapCents: 40000,
              terms: '2.5% en recargas de combustible.',
            ),
          ],
          createdAt: DateTime(2026, 2, 10),
          updatedAt: DateTime(2026, 9, 1),
        ),
        UserCard(
          id: 'card_demo_prisma',
          userId: 'usr_demo',
          issuerId: 'iss_prisma',
          issuerName: 'Banco Prisma (Demo)',
          productName: 'Prisma Cashback Directo',
          alias: 'Prisma 2%',
          type: 'credit',
          last4: '2055',
          currency: 'MXN',
          creditLimitCents: 4000000, // $40,000.00
          currentBalanceCents: 850000, // $8,500.00
          availableCreditCents: 3150000, // $31,500.00
          statementClosingDay: 5,
          paymentDueDay: 25,
          daysBetweenCutoffAndDue: 20,
          adjustForHolidays: true,
          colorHex: '#00A86B', // Verde esmeralda fintech
          status: 'active',
          notes: '2% parejo en compras en línea y servicios.',
          benefits: [
            const Benefit(
              id: 'ben_prisma_all',
              category: 'all',
              rewardType: 'cashback',
              rewardRate: 2.0,
              rewardCapCents: 80000,
              terms: '2% cashback mensual en cualquier establecimiento.',
            ),
          ],
          createdAt: DateTime(2026, 3, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
        UserCard(
          id: 'card_demo_debito',
          userId: 'usr_demo',
          issuerId: 'iss_horizonte',
          issuerName: 'Banco Horizonte (Demo)',
          productName: 'Cuenta Nómina Débito',
          alias: 'Nómina Principal',
          type: 'debit',
          last4: '4410',
          currency: 'MXN',
          creditLimitCents: 0,
          currentBalanceCents: 0,
          availableCreditCents: 2450000, // $24,500.00 en saldo
          statementClosingDay: 1,
          paymentDueDay: 1,
          daysBetweenCutoffAndDue: 0,
          colorHex: '#484F58',
          status: 'active',
          notes: 'Tarjeta de débito para retiros y gastos diarios.',
          benefits: const [],
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      ];
}
