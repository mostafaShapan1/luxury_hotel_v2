import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'modify_booking_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // TODO: Replace '1' with actual user ID from auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings('1');
    });
  }

  Future<void> _handleCancelBooking(String bookingId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<BookingProvider>(context, listen: false)
            .cancelBooking(bookingId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to cancel booking: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleModifyBooking(BuildContext context, Booking booking) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ModifyBookingScreen(booking: booking),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking modified successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, child) {
          if (bookingProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGold,
              ),
            );
          }

          final bookings = bookingProvider.getBookingsByUserId('1');

          if (bookings.isEmpty) {
            return const Center(
              child: Text(
                'No bookings found',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              final bool isActive = booking.status != 'cancelled' &&
                  booking.checkOut.isAfter(DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.roomName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.primaryGold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check-in: ${booking.checkIn.day}/${booking.checkIn.month}/${booking.checkIn.year}',
                      ),
                      Text(
                        'Check-out: ${booking.checkOut.day}/${booking.checkOut.month}/${booking.checkOut.year}',
                      ),
                      Text('Guests: ${booking.guests}'),
                      Text(
                        'Total: \$${booking.totalPrice.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: booking.status == 'cancelled'
                              ? Colors.red
                              : isActive
                                  ? Colors.green
                                  : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          booking.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _handleModifyBooking(context, booking),
                              child: const Text('Modify'),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () =>
                                  _handleCancelBooking(booking.id),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
