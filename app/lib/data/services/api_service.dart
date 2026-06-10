import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/venue.dart';
import '../models/slot.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../../core/constants/api_constants.dart';
import '../../core/exceptions/app_exception.dart';

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

class ApiService {
  final http.Client _client = http.Client();

  /// JWT token stored after login/register
  String? _token;

  /// Set the token after successful auth
  void setToken(String token) => _token = token;

  /// Clear token on logout
  void clearToken() => _token = null;

  /// Auth headers with Bearer token
  Map<String, String> _authHeaders() => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// Handle HTTP response errors
  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 409:
        final body = jsonDecode(response.body);
        throw ConflictException(body['detail'] ?? 'Slot already booked');
      case 401:
        final body = jsonDecode(response.body);
        throw ApiException(body['detail'] ?? 'Invalid credentials',
            statusCode: 401);
      case 404:
        final body = jsonDecode(response.body);
        throw NotFoundException(body['detail'] ?? 'Not found');
      case 403:
        final body = jsonDecode(response.body);
        throw ForbiddenException(body['detail'] ?? 'Not authorized');
      case 422:
        String message = 'Validation error';
        try {
          final body = jsonDecode(response.body);
          final details = body['detail'];
          if (details is List && details.isNotEmpty) {
            message = details[0]['msg'] ?? message;
          } else if (details is String) {
            message = details;
          }
        } catch (_) {}
        throw ApiException(message, statusCode: 422);
      default:
        if (response.statusCode >= 400) {
          String message = 'Something went wrong';
          try {
            final body = jsonDecode(response.body);
            message = body['detail'] ?? message;
          } catch (_) {}
          throw ApiException(message, statusCode: response.statusCode);
        }
    }
  }

  // ──── Auth ────

  Future<AuthResponse> register(String name, String email, String password) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authRegister}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    _handleError(response);
    final authResp = AuthResponse.fromJson(jsonDecode(response.body));
    _token = authResp.token;
    return authResp;
  }

  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authLogin}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    _handleError(response);
    final authResp = AuthResponse.fromJson(jsonDecode(response.body));
    _token = authResp.token;
    return authResp;
  }

  Future<User> getProfile() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/auth/profile'),
      headers: _authHeaders(),
    );
    _handleError(response);
    return User.fromJson(jsonDecode(response.body));
  }

  Future<User> updateProfile({String? name, String? phone, String? bio, String? avatar}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (bio != null) body['bio'] = bio;
    if (avatar != null) body['avatar'] = avatar;

    final response = await _client.put(
      Uri.parse('${ApiConstants.baseUrl}/auth/profile'),
      headers: _authHeaders(),
      body: jsonEncode(body),
    );
    _handleError(response);
    return User.fromJson(jsonDecode(response.body));
  }

  // ──── Venues ────

  Future<List<Venue>> getVenues() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.venues}'),
    );
    _handleError(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Venue.fromJson(json)).toList();
  }

  // ──── Slots ────

  Future<List<Slot>> getSlots(int venueId, String date) async {
    final response = await _client.get(
      Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.venues}/$venueId/slots?date=$date'),
    );
    _handleError(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Slot.fromJson(json)).toList();
  }

  // ──── Bookings ────

  Future<Booking> createBooking(int slotId) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}'),
      headers: _authHeaders(),
      body: jsonEncode({'slot_id': slotId}),
    );
    _handleError(response);
    return Booking.fromJson(jsonDecode(response.body));
  }

  Future<void> cancelBooking(int bookingId) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.bookings}/$bookingId'),
      headers: _authHeaders(),
    );
    _handleError(response);
  }

  // ──── User Bookings ────

  Future<List<Booking>> getMyBookings() async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}${ApiConstants.users}/me/bookings'),
      headers: _authHeaders(),
    );
    _handleError(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Booking.fromJson(json)).toList();
  }
}
