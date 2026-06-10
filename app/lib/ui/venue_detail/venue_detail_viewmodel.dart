import 'package:flutter/material.dart';
import '../../data/models/slot.dart';
import '../../data/services/api_service.dart';
import '../../core/exceptions/app_exception.dart';

class VenueDetailViewModel extends ChangeNotifier {
  final ApiService _apiService;

  VenueDetailViewModel(this._apiService);

  List<Slot> _slots = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  bool _isBooking = false;

  // Booking result feedback
  String? _bookingSuccess;
  String? _bookingError;

  List<Slot> get slots => _slots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  bool get isBooking => _isBooking;
  String? get bookingSuccess => _bookingSuccess;
  String? get bookingError => _bookingError;

  void clearBookingFeedback() {
    _bookingSuccess = null;
    _bookingError = null;
  }

  void setDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  String get formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> fetchSlots(int venueId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _slots = await _apiService.getSlots(venueId, formattedDate);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookSlot(int slotId, int venueId) async {
    _isBooking = true;
    _bookingSuccess = null;
    _bookingError = null;
    notifyListeners();

    try {
      await _apiService.createBooking(slotId);
      _bookingSuccess = 'Booked successfully! ✅';
      await fetchSlots(venueId); // Refresh grid
    } on ConflictException {
      _bookingError = 'This slot was just taken by someone else!';
      await fetchSlots(venueId); // Refresh to show updated state
    } catch (e) {
      _bookingError = 'Something went wrong. Please try again.';
    } finally {
      _isBooking = false;
      notifyListeners();
    }
  }
}
