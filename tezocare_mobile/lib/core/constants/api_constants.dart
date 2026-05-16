class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://192.168.0.119:8000';

  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String forgotPassword = '/api/v1/auth/forgot-password';
  static const String verifyOtp = '/api/v1/auth/verify-otp';
  static const String resetPassword = '/api/v1/auth/reset-password';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String currentUser = '/api/v1/auth/me';
  static const String patients = '/api/v1/patients/';
  static const String visits = '/api/v1/visits';
  static const String vitals = '/api/v1/vitals';
  static const String medications = '/api/v1/medications';
  static const String dashboardStats = '/api/v1/dashboard/stats';
  static const String refillsDue = '/api/v1/dashboard/refills-due';

  static const String accessTokenKey = 'tezocare_access_token';
  static const String refreshTokenKey = 'tezocare_refresh_token';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
