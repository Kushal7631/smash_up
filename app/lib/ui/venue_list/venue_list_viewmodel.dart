import 'package:flutter/material.dart';
import '../../data/models/venue.dart';
import '../../data/services/api_service.dart';

class VenueListViewModel extends ChangeNotifier {
  final ApiService _apiService;

  VenueListViewModel(this._apiService);

  List<Venue> _venues = [];
  bool _isLoading = false;
  String? _error;

  List<Venue> get venues => _venues;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchVenues() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _venues = await _apiService.getVenues();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
