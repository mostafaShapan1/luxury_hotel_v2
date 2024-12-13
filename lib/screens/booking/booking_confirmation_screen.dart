import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/room.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';
import 'booking_history_screen.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookings;

  const BookingConfirmationScreen({Key? key, required this.bookings})
      : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  Widget _buildDetailsCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      color: AppTheme.softBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppTheme.primaryGold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: AppTheme.primaryGold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.bookings['room'] as Room;
    final checkIn = widget.bookings['checkIn'] as DateTime;
    final checkOut = widget.bookings['checkOut'] as DateTime;
    final guests = widget.bookings['guests'] as int;
    final totalPrice = widget.bookings['totalPrice'] as double;
    final bookingId = widget.bookings['id'] as String;
    final status = widget.bookings['status'] as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.primaryGold,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryGold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your reservation has been successfully confirmed.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            _buildDetailsCard(
              context,
              title: 'Booking Details',
              children: [
                _buildDetailRow('Booking ID', bookingId),
                _buildDetailRow('Room Type', room.name),
                _buildDetailRow(
                    'Check-in', '${checkIn.day}/${checkIn.month}/${checkIn.year}'),
                _buildDetailRow('Check-out',
                    '${checkOut.day}/${checkOut.month}/${checkOut.year}'),
                _buildDetailRow('Guests', guests.toString()),
                _buildDetailRow('Total Price', '\$${totalPrice.toStringAsFixed(2)}'),
                _buildDetailRow('Status', status.toUpperCase()),
                _buildInfoRow('Room Description', room.description),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () async {
                  final booking = Booking(
                    id: bookingId,
                    roomId: room.id,
                    userId: '1', // Replace with actual user ID
                    checkIn: checkIn,
                    checkOut: checkOut,
                    guests: guests,
                    totalPrice: totalPrice,
                    roomName: room.name,
                    status: status,
                  );

                  try {
                    await Provider.of<BookingProvider>(context, listen: false)
                        .addBooking(booking);
                        
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingHistoryScreen(),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error saving booking: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'View Booking History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
