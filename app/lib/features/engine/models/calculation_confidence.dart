enum CalculationConfidence {
  confirmed,
  estimated,
  insufficientData;

  String get label {
    switch (this) {
      case CalculationConfidence.confirmed:
        return 'Verificado';
      case CalculationConfidence.estimated:
        return 'Estimado';
      case CalculationConfidence.insufficientData:
        return 'Datos Incompletos';
    }
  }

  String get description {
    switch (this) {
      case CalculationConfidence.confirmed:
        return 'Fechas y condiciones verificadas con los términos registrados.';
      case CalculationConfidence.estimated:
        return 'Calculado con la regla estándar del emisor. Confirma con tu estado de cuenta.';
      case CalculationConfidence.insufficientData:
        return 'Faltan datos de corte o pago para ofrecer certeza matemática.';
    }
  }
}
