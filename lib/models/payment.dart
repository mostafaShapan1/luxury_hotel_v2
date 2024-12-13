class Payment {
  final String id;
  final String bookingId;
  final String method; // 'visa' or 'cash'
  final double amount;
  final String status; // 'pending', 'completed', 'failed'
  final DateTime timestamp;
  final Map<String, dynamic>? cardDetails; // Only for visa payments

  Payment({
    required this.id,
    required this.bookingId,
    required this.method,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.cardDetails,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['bookingId'],
      method: json['method'],
      amount: json['amount'].toDouble(),
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
      cardDetails: json['cardDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'method': method,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'cardDetails': cardDetails,
    };
  }
}
