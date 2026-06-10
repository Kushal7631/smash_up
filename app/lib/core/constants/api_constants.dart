import 'env_config.dart';

class ApiConstants {
  static String get baseUrl => EnvConfig.baseUrl;

  static const String venues = '/venues';
  static const String bookings = '/bookings';
  static const String users = '/users';
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
}
