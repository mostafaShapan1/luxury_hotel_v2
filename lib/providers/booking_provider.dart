import 'package:flutter/material.dart';
import '../models/booking.dart';

class BookingProvider with ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  Future<void> fetchBookings(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate fetching bookings from a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBooking(Booking newBooking) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate adding booking to a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      _bookings.add(newBooking);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding booking: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBooking(Booking updatedBooking) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate updating booking in a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _bookings.indexWhere((b) => b.id == updatedBooking.id);
      if (index != -1) {
        _bookings[index] = updatedBooking;
        notifyListeners();
      } else {
        throw Exception('Booking not found');
      }
    } catch (e) {
      debugPrint('Error updating booking: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate canceling booking in a database or API
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = Booking(
          id: _bookings[index].id,
          userId: _bookings[index].userId,
          roomId: _bookings[index].roomId,
          roomName: _bookings[index].roomName,
          checkIn: _bookings[index].checkIn,
          checkOut: _bookings[index].checkOut,
          guests: _bookings[index].guests,
          totalPrice: _bookings[index].totalPrice,
          status: 'cancelled',
        );
        notifyListeners();
      } else {
        throw Exception('Booking not found');
      }
    } catch (e) {
      debugPrint('Error canceling booking: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Booking> getBookingsByUserId(String userId) {
    return _bookings.where((booking) => booking.userId == userId).toList();
  }

  Booking? getBookingById(String bookingId) {
    try {
      return _bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }
}
