class AppConstants {
  AppConstants._();

  static const String appName = 'Wallet AI';
  static const String appVersion = '1.0.0';
  static const String defaultCurrency = 'MXN';

  // Categorías de compras soportadas
  static const List<String> purchaseCategories = [
    'supermarket',
    'dining',
    'fuel',
    'travel',
    'online',
    'entertainment',
    'health',
    'education',
    'services',
    'other',
  ];

  static String getCategoryLabel(String category) {
    switch (category) {
      case 'supermarket':
        return 'Supermercado';
      case 'dining':
        return 'Restaurantes';
      case 'fuel':
        return 'Gasolina';
      case 'travel':
        return 'Viajes';
      case 'online':
        return 'Compras en Línea';
      case 'entertainment':
        return 'Entretenimiento';
      case 'health':
        return 'Salud y Farmacia';
      case 'education':
        return 'Educación';
      case 'services':
        return 'Servicios y Recibos';
      case 'all':
        return 'Todas las compras';
      default:
        return 'Otros';
    }
  }

  static String getCategoryIcon(String category) {
    switch (category) {
      case 'supermarket':
        return '🛒';
      case 'dining':
        return '🍽️';
      case 'fuel':
        return '⛽';
      case 'travel':
        return '✈️';
      case 'online':
        return '🛍️';
      case 'entertainment':
        return '🎬';
      case 'health':
        return '💊';
      case 'education':
        return '📚';
      case 'services':
        return '💡';
      default:
        return '💳';
    }
  }
}
