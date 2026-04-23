class ApiConstants {
  static const String baseUrl = 'http://localhost:3000/api'; // API Gateway

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyToken = '/auth/verify';
  static const String refreshToken = '/auth/refresh';

  // Users
  static const String users = '/users';

  // Products
  static const String products = '/products';

  // Inventory
  static const String inventory = '/inventory';
  static const String stockMovements = '/inventory/movements';
  static const String stockAlerts = '/inventory/alerts';

  // Orders
  static const String orders = '/orders';

  // Production
  static const String production = '/production';
  static const String machines = '/production/machines';

  // Billing
  static const String factures = '/billing/factures';
  static const String paiements = '/billing/factures'; // avec /:id/paiement
  static const String billingStats = '/billing/stats';

  // Notifications
  static const String notifications = '/notifications';

  // Reporting
  static const String dashboard = '/reporting/dashboard';
  static const String salesReport = '/reporting/ventes';
  static const String stockReport = '/reporting/stock';
  static const String productionReport = '/reporting/production';
  static const String financeReport = '/reporting/finances';
}