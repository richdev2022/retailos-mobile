/// Typed, centralized backend endpoint paths for RetailOS.
///
/// All paths are relative to the API base URL (which ends in `/api/v1`).
/// Keeping them in one place avoids typos and makes refactorings trivial.
///
/// Usage:
///   apiClient.post(ApiEndpoints.authLogin, data: {...});
class ApiEndpoints {
  ApiEndpoints._();

  // ---- Auth ----
  static const String authRegister = 'auth/register';
  static const String authLogin = 'auth/login';
  static const String authRefresh = 'auth/refresh';
  static const String authLogout = 'auth/logout';
  static const String authMe = 'auth/me';
  static const String authForgotPassword = 'auth/forgot-password';
  static const String authResetPassword = 'auth/reset-password';
  static const String authVerifyEmail = 'auth/verify-email';
  static const String authResendVerification = 'auth/resend-verification';

  /// Invitations: accept via token query param `?token=`.
  static String authAcceptInvitation(String token) =>
      'auth/accept-invitation?token=$token';

  // ---- Businesses ----
  static const String businesses = 'businesses';
  static String business(String id) => 'businesses/$id';
  static String businessMemberships(String id) => 'businesses/$id/memberships';

  // ---- Branches ----
  static const String branches = 'branches';
  static String branch(String id) => 'branches/$id';

  // ---- Memberships / staff ----
  static const String memberships = 'memberships';
  static String membership(String id) => 'memberships/$id';
  static const String staffInvite = 'memberships/invite';

  // ---- Products ----
  static const String products = 'products';
  static String product(String id) => 'products/$id';
  static const String productLookup = 'products/lookup'; // by barcode/sku

  // ---- Inventory / stock movements ----
  static const String inventory = 'inventory';
  static const String stockMovements = 'inventory/movements';
  static String productStock(String productId) => 'inventory/$productId';
  static const String stockAdjust = 'inventory/adjust';

  // ---- Sales / POS ----
  static const String sales = 'sales';
  static String sale(String id) => 'sales/$id';
  static const String salesSummary = 'sales/summary';
  static const String salesByReceipt = 'sales/by-receipt';

  // ---- Customers ----
  static const String customers = 'customers';
  static String customer(String id) => 'customers/$id';

  // ---- Suppliers ----
  static const String suppliers = 'suppliers';
  static String supplier(String id) => 'suppliers/$id';

  // ---- Purchases ----
  static const String purchases = 'purchases';
  static String purchase(String id) => 'purchases/$id';

  // ---- Expenses ----
  static const String expenses = 'expenses';
  static String expense(String id) => 'expenses/$id';

  // ---- Reports ----
  static const String reportsDashboard = 'reports/dashboard';
  static const String reportsSales = 'reports/sales';
  static const String reportsInventory = 'reports/inventory';
  static const String reportsPnl = 'reports/profit-loss';

  // ---- Subscriptions ----
  static const String subscriptionPlans = 'subscription/plans';
  static const String subscriptionCurrent = 'subscription/current';
  static const String subscriptionInitiate = 'subscription/initiate';
  static const String subscriptionCancel = 'subscription/cancel';

  // ---- Notifications ----
  static const String notifications = 'notifications';
  static String notificationMarkRead(String id) => 'notifications/$id/read';
  static const String notificationMarkAllRead = 'notifications/read-all';
  static const String notificationRegisterDevice = 'notifications/device';

  // ---- Support ----
  static const String supportTickets = 'support/tickets';
  static String supportTicket(String id) => 'support/tickets/$id';

  // ---- Sync ----
  static const String syncPush = 'sync/push';
  static const String syncPull = 'sync/pull';
  static const String syncStatus = 'sync/status';

  // ---- File uploads ----
  static const String uploads = 'uploads';
}
