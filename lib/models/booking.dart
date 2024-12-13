import 'room.dart';

class Booking {
  final String id;
  final String userId;
  final String roomId;
  final String roomName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.roomName,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      roomId: json['roomId'],
      roomName: json['roomName'],
      checkIn: DateTime.parse(json['checkIn']),
      checkOut: DateTime.parse(json['checkOut']),
      guests: json['guests'],
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roomId': roomId,
      'roomName': roomName,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'guests': guests,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
