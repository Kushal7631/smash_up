/// Environment configuration for managing API base URL.
/// Change the active environment here before running.
class EnvConfig {
  static const Environment _currentEnv = Environment.production;

  static String get baseUrl {
    switch (_currentEnv) {
      case Environment.dev:
        return 'http://10.0.2.2:8000'; // Android emulator → host machine
      case Environment.staging:
        return 'http://192.168.1.100:8000'; // Replace with your LAN IP
      case Environment.production:
        return 'https://smashup-api.onrender.com'; // Render production server
      case Environment.ios:
        return 'http://localhost:8000'; // iOS simulator
      case Environment.physical:
        return 'http://192.168.1.100:8000'; // Physical device (use your machine IP)
    }
  }
}

enum Environment {
  dev,       // Android emulator
  ios,       // iOS simulator
  staging,   // Staging server
  production,// Production server
  physical,  // Physical device on same network
}
