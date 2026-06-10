import 'package:flutter/material.dart';
import '../../data/models/user.dart';
import '../../data/services/api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final ApiService _apiService;

  LoginViewModel(this._apiService);

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  int? get userId => _currentUser?.id;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get currentUserName => _currentUser?.name ?? '';

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.login(email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.register(name, email, password);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? bio, String? avatar}) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _apiService.updateProfile(
        _currentUser!.id,
        name: name,
        phone: phone,
        bio: bio,
        avatar: avatar,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
