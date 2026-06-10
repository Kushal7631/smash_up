import 'package:flutter/material.dart';
import '../../data/models/booking.dart';
import '../../data/services/api_service.dart';

class MyBookingsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  MyBookingsViewModel(this._apiService);

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _cancelMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get cancelMessage => _cancelMessage;

  void clearCancelMessage() {
    _cancelMessage = null;
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await _apiService.getMyBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _apiService.cancelBooking(bookingId);
      _cancelMessage = 'Booking cancelled';
      await fetchBookings(); // Refresh list
    } catch (e) {
      _cancelMessage = 'Failed to cancel: ${e.toString()}';
      notifyListeners();
    }
  }
}
