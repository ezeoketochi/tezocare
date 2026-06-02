class ApiConstants {
  ApiConstants._();

  //static const String baseUrl = 'http://192.168.0.119:8000';
  static const String baseUrl = 'http://192.168.8.102:8000';

  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String refreshToken = '/api/v1/auth/refresh-token';
  static const String currentUser = '/api/v1/auth/me';
  static const String patients = '/api/v1/patients/';
  static const String visits = '/api/v1/visits/';
  static const String dashboardSummary = '/api/v1/dashboard/summary';
  static const String dashboardDueRefills = '/api/v1/dashboard/due-refills';
  static const String refills = '/api/v1/refills';
  static const String dashboardDueFollowUps = '/api/v1/dashboard/due-followups';
  static const String fcmToken = '/api/v1/staff/fcm-token';

  static const String accessTokenKey = 'tezocare_access_token';
  static const String refreshTokenKey = 'tezocare_refresh_token';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
