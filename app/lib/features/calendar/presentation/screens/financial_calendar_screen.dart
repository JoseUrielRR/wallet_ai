import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../engine/domain/billing_cycle_engine.dart';
import '../providers/calendar_provider.dart';

class FinancialCalendarScreen extends ConsumerStatefulWidget {
  const FinancialCalendarScreen({super.key});

  @override
  ConsumerState<FinancialCalendarScreen> createState() => _FinancialCalendarScreenState();
}

class _FinancialCalendarScreenState extends ConsumerState<FinancialCalendarScreen> {
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(calendarEventsProvider);

    final daysInCurrentMonth = BillingCycleEngine.daysInMonth(_focusedMonth.year, _focusedMonth.month);
    final firstWeekdayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday;
    // DateTime.weekday: Monday is 1, Sunday is 7. Normalizing to 0 (Sunday) to 6 (Saturday)
    final leadingBlanks = firstWeekdayOfMonth == 7 ? 0 : firstWeekdayOfMonth;

    // Filtrar eventos para el día seleccionado
    final selectedDayEvents = allEvents.where((e) {
      return e.date.year == _selectedDay.year &&
          e.date.month == _selectedDay.month &&
          e.date.day == _selectedDay.day;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario Financiero', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Selector de Mes y Año
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _prevMonth,
                ),
                Text(
                  '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),

          // Leyenda de eventos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem('🔵 Corte', AppColors.brandSecondary),
                _buildLegendItem('🟠 Pago Tarjeta', AppColors.warning),
                _buildLegendItem('🟣 Préstamo', AppColors.brandPurple),
                _buildLegendItem('🟢 Compra', AppColors.success),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Días de la semana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'].map((day) {
                return Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: AppColors.textSubtleDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Cuadrícula del Calendario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadingBlanks + daysInCurrentMonth,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                if (index < leadingBlanks) {
                  return const SizedBox.shrink();
                }

                final dayNumber = index - leadingBlanks + 1;
                final dayDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
                final isSelected = dayDate.year == _selectedDay.year &&
                    dayDate.month == _selectedDay.month &&
                    dayDate.day == _selectedDay.day;

                // Eventos en este día
                final dayEvents = allEvents.where((e) {
                  return e.date.year == dayDate.year &&
                      e.date.month == dayDate.month &&
                      e.date.day == dayDate.day;
                }).toList();

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDay = dayDate;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.brandPrimary.withValues(alpha: 0.25)
                          : AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.brandPrimary
                            : AppColors.darkBorder.withValues(alpha: 0.5),
                        width: isSelected ? 1.5 : 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isSelected ? AppColors.brandPrimary : AppColors.textHighDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: dayEvents.take(3).map((e) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: _parseColor(e.colorHex),
                                    shape: BoxShape.circle,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.darkBorder),

          // Título de eventos del día seleccionado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Eventos del ${DateFormatter.formatShort(_selectedDay)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${selectedDayEvents.length} eventos',
                  style: const TextStyle(color: AppColors.textMediumDark, fontSize: 12),
                ),
              ],
            ),
          ),

          // Lista de eventos del día
          Expanded(
            child: selectedDayEvents.isEmpty
                ? const Center(
                    child: Text(
                      'No hay cortes ni pagos programados para este día.',
                      style: TextStyle(color: AppColors.textSubtleDark),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];
                      final color = _parseColor(event.colorHex);

                      return Card(
                        color: AppColors.darkSurface,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.darkBorder),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(
                            event.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            event.subtitle,
                            style: const TextStyle(color: AppColors.textMediumDark, fontSize: 12),
                          ),
                          trailing: event.amountCents != null
                              ? Text(
                                  MoneyFormatter.formatCents(event.amountCents!),
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return AppColors.brandPrimary;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }
}
