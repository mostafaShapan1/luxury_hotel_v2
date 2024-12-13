import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../theme/app_theme.dart';

class ModifyBookingScreen extends StatefulWidget {
  final Booking booking;

  const ModifyBookingScreen({Key? key, required this.booking}) : super(key: key);

  @override
  State<ModifyBookingScreen> createState() => _ModifyBookingScreenState();
}

class _ModifyBookingScreenState extends State<ModifyBookingScreen> {
  late DateTime _checkIn;
  late DateTime _checkOut;
  late int _guests;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.booking.checkIn;
    _checkOut = widget.booking.checkOut;
    _guests = widget.booking.guests;
  }

  Future<void> _updateBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_checkIn.isAfter(_checkOut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check-in date must be before check-out date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedBooking = Booking(
        id: widget.booking.id,
        userId: widget.booking.userId,
        roomId: widget.booking.roomId,
        roomName: widget.booking.roomName,
        checkIn: _checkIn,
        checkOut: _checkOut,
        guests: _guests,
        totalPrice: widget.booking.totalPrice,
        status: widget.booking.status,
      );

      await Provider.of<BookingProvider>(context, listen: false)
          .updateBooking(updatedBooking);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? _checkIn : _checkOut,
      firstDate: isCheckIn ? DateTime.now() : _checkIn,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGold,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
          if (_checkIn.isAfter(_checkOut)) {
            _checkOut = _checkIn.add(const Duration(days: 1));
          }
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modify Booking'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room: ${widget.booking.roomName}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ListTile(
                title: const Text('Check-in Date'),
                subtitle: Text(
                  '${_checkIn.day}/${_checkIn.month}/${_checkIn.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              ListTile(
                title: const Text('Check-out Date'),
                subtitle: Text(
                  '${_checkOut.day}/${_checkOut.month}/${_checkOut.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _guests.toString(),
                decoration: const InputDecoration(
                  labelText: 'Number of Guests',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of guests';
                  }
                  final guests = int.tryParse(value);
                  if (guests == null || guests < 1) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  final guests = int.tryParse(value);
                  if (guests != null && guests > 0) {
                    setState(() {
                      _guests = guests;
                    });
                  }
                },
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
                  onPressed: _isLoading ? null : _updateBooking,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Update Booking',
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
      ),
    );
  }
}
