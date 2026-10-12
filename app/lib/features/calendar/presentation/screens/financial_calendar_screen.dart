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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

    final primaryTextColor = isDark ? AppColors.textHighDark : AppColors.slate900;
    final secondaryTextColor = isDark ? AppColors.textMediumDark : AppColors.slate500;
    final cardBgColor = isDark ? AppColors.darkSurface : AppColors.softSurface;
    final cardBorderColor = isDark ? AppColors.darkBorder : AppColors.softBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.softBackground,
        elevation: 0,
        title: Text(
          'Calendario Financiero',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: primaryTextColor,
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          final isLandscape = orientation == Orientation.landscape;

          if (isLandscape) {
            // Layout adaptativo para orientación horizontal (Landscape)
            // Divide la pantalla en dos columnas scrollables: Calendario a la izquierda y Eventos a la derecha
            return SingleChildScrollView(
              key: const Key('calendar_scroll_view'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Columna Izquierda: Calendario
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: cardBorderColor, width: 1),
                        boxShadow: isDark ? null : const [AppColors.softShadow],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMonthSelector(primaryTextColor),
                          const SizedBox(height: 6),
                          _buildLegendRow(isDark),
                          const SizedBox(height: 10),
                          _buildWeekdaysRow(secondaryTextColor),
                          const SizedBox(height: 6),
                          _buildCalendarGrid(
                            leadingBlanks: leadingBlanks,
                            daysInCurrentMonth: daysInCurrentMonth,
                            allEvents: allEvents,
                            isDark: isDark,
                            primaryTextColor: primaryTextColor,
                            childAspectRatio: 1.3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Columna Derecha: Eventos del día seleccionado
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: cardBorderColor, width: 1),
                        boxShadow: isDark ? null : const [AppColors.softShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSelectedDayHeader(
                            selectedDayEvents: selectedDayEvents,
                            primaryTextColor: primaryTextColor,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _buildEventList(
                            selectedDayEvents: selectedDayEvents,
                            isDark: isDark,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            cardBorderColor: cardBorderColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Layout para orientación vertical (Portrait)
          // Todo el cuerpo está dentro de un SingleChildScrollView para garantizar cero desbordamientos
          return SingleChildScrollView(
            key: const Key('calendar_scroll_view'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta Principal del Calendario
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cardBorderColor, width: 1),
                    boxShadow: isDark ? null : const [AppColors.softShadow],
                  ),
                  child: Column(
                    children: [
                      _buildMonthSelector(primaryTextColor),
                      const SizedBox(height: 8),
                      _buildLegendRow(isDark),
                      const SizedBox(height: 12),
                      _buildWeekdaysRow(secondaryTextColor),
                      const SizedBox(height: 6),
                      _buildCalendarGrid(
                        leadingBlanks: leadingBlanks,
                        daysInCurrentMonth: daysInCurrentMonth,
                        allEvents: allEvents,
                        isDark: isDark,
                        primaryTextColor: primaryTextColor,
                        childAspectRatio: 1.15,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Encabezado de Eventos del Día
                _buildSelectedDayHeader(
                  selectedDayEvents: selectedDayEvents,
                  primaryTextColor: primaryTextColor,
                  isDark: isDark,
                ),

                const SizedBox(height: 8),

                // Lista de Eventos
                _buildEventList(
                  selectedDayEvents: selectedDayEvents,
                  isDark: isDark,
                  primaryTextColor: primaryTextColor,
                  secondaryTextColor: secondaryTextColor,
                  cardBorderColor: cardBorderColor,
                ),

                const SizedBox(height: 28),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Selector de Mes y Año con navegación
  Widget _buildMonthSelector(Color primaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: primaryTextColor),
          onPressed: _prevMonth,
          tooltip: 'Mes anterior',
        ),
        Expanded(
          child: Center(
            child: Text(
              '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
              style: TextStyle(
                fontSize: 17.5,
                fontWeight: FontWeight.w800,
                color: primaryTextColor,
                letterSpacing: -0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right_rounded, color: primaryTextColor),
          onPressed: _nextMonth,
          tooltip: 'Mes siguiente',
        ),
      ],
    );
  }

  /// Leyenda de tipos de evento en chips pastel con alto contraste
  Widget _buildLegendRow(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendChip(
            label: 'Corte',
            color: isDark ? AppColors.info : AppColors.pastelSkyText,
            bg: isDark ? AppColors.info.withValues(alpha: 0.15) : AppColors.pastelSkyBg,
          ),
          const SizedBox(width: 6),
          _buildLegendChip(
            label: 'Pago Tarjeta',
            color: isDark ? AppColors.warningLight : AppColors.pastelAmberText,
            bg: isDark ? AppColors.warning.withValues(alpha: 0.15) : AppColors.pastelAmberBg,
          ),
          const SizedBox(width: 6),
          _buildLegendChip(
            label: 'Préstamo',
            color: isDark ? AppColors.brandPurple : AppColors.pastelLavenderText,
            bg: isDark ? AppColors.brandPurple.withValues(alpha: 0.15) : AppColors.pastelLavenderBg,
          ),
          const SizedBox(width: 6),
          _buildLegendChip(
            label: 'Compra',
            color: isDark ? AppColors.brandPrimaryLight : AppColors.pastelMintText,
            bg: isDark ? AppColors.brandPrimary.withValues(alpha: 0.15) : AppColors.pastelMintBg,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendChip({
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4.5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Fila de nombres de días de la semana
  Widget _buildWeekdaysRow(Color secondaryTextColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'].map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                color: secondaryTextColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Cuadrícula mensual de días del calendario
  Widget _buildCalendarGrid({
    required int leadingBlanks,
    required int daysInCurrentMonth,
    required List<FinancialEvent> allEvents,
    required bool isDark,
    required Color primaryTextColor,
    required double childAspectRatio,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: leadingBlanks + daysInCurrentMonth,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: childAspectRatio,
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

        final dayEvents = allEvents.where((e) {
          return e.date.year == dayDate.year &&
              e.date.month == dayDate.month &&
              e.date.day == dayDate.day;
        }).toList();

        final now = DateTime.now();
        final isToday = dayDate.year == now.year &&
            dayDate.month == now.month &&
            dayDate.day == now.day;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDay = dayDate;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? AppColors.brandPrimary.withValues(alpha: 0.25)
                      : AppColors.pastelMintBg)
                  : (isDark ? AppColors.darkSurfaceElevated : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.brandPrimary
                    : (isToday
                        ? AppColors.brandPrimary.withValues(alpha: 0.6)
                        : (isDark
                            ? AppColors.darkBorder.withValues(alpha: 0.5)
                            : AppColors.softBorderSubtle)),
                width: isSelected ? 1.5 : (isToday ? 1.2 : 0.8),
              ),
              boxShadow: isDark || isSelected
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x040F172A),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNumber',
                  style: TextStyle(
                    color: isSelected
                        ? (isDark ? AppColors.brandPrimaryLight : AppColors.pastelMintText)
                        : primaryTextColor,
                    fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (dayEvents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.5),
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
                  )
                else
                  const SizedBox(height: 7.5),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Encabezado con la fecha seleccionada y contador de eventos
  Widget _buildSelectedDayHeader({
    required List<FinancialEvent> selectedDayEvents,
    required Color primaryTextColor,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Eventos del ${DateFormatter.formatShort(_selectedDay)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15.5,
              color: primaryTextColor,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.brandPrimary.withValues(alpha: 0.15)
                : AppColors.pastelMintBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${selectedDayEvents.length} eventos',
            style: const TextStyle(
              color: AppColors.pastelMintText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  /// Lista de eventos del día seleccionado con diseño Soft UI
  Widget _buildEventList({
    required List<FinancialEvent> selectedDayEvents,
    required bool isDark,
    required Color primaryTextColor,
    required secondaryTextColor,
    required Color cardBorderColor,
  }) {
    if (selectedDayEvents.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.softSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorderColor, width: 0.8),
        ),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: secondaryTextColor.withValues(alpha: 0.7),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'No hay cortes ni pagos programados para este día.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: selectedDayEvents.map((event) {
        final color = _parseColor(event.colorHex);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDark
                ? null
                : const [
                    BoxShadow(
                      color: Color(0x060F172A),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Material(
            color: isDark ? AppColors.darkSurface : AppColors.softSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: isDark ? AppColors.glassWhite : AppColors.softBorder,
                width: 0.8,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              title: Text(
                event.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  color: primaryTextColor,
                ),
              ),
              subtitle: Text(
                event.subtitle,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              trailing: event.amountCents != null
                  ? Text(
                      MoneyFormatter.formatCents(event.amountCents!),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                      ),
                    )
                  : null,
            ),
          ),
        );
      }).toList(),
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
