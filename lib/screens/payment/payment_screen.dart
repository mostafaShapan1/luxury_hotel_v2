import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/payment.dart';
import '../../providers/payment_provider.dart';
import '../../theme/app_theme.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String bookingId;

  const PaymentScreen({
    Key? key,
    required this.amount,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'visa';
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildPaymentMethodCard({
    required String title,
    required IconData icon,
    required String method,
    required String description,
  }) {
    final isSelected = _selectedMethod == method;
    
    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGold : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMethod = method;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 32,
                    color: isSelected ? AppTheme.primaryGold : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppTheme.primaryGold : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryGold,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == 'visa' && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final payment = Payment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        bookingId: widget.bookingId,
        method: _selectedMethod,
        amount: widget.amount,
        status: 'completed',
        timestamp: DateTime.now(),
        cardDetails: _selectedMethod == 'visa'
            ? {
                'cardNumber': _cardNumberController.text,
                'expiry': _expiryController.text,
                'name': _nameController.text,
              }
            : null,
      );

      await Provider.of<PaymentProvider>(context, listen: false)
          .processPayment(payment);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Widget _buildVisaForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardNumberController,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter card number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    hintText: '123',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Cardholder Name',
              hintText: 'JOHN DOE',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter cardholder name';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Amount: \$${widget.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodCard(
              title: 'Credit/Debit Card',
              icon: Icons.credit_card,
              method: 'visa',
              description: 'Pay securely with your credit or debit card',
            ),
            const SizedBox(height: 12),
            _buildPaymentMethodCard(
              title: 'Cash Payment',
              icon: Icons.payments_outlined,
              method: 'cash',
              description: 'Pay in cash during check-in at the hotel',
            ),
            const SizedBox(height: 24),
            if (_selectedMethod == 'visa') ...[
              const Text(
                'Card Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildVisaForm(),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _selectedMethod == 'visa' ? 'Pay Now' : 'Confirm Cash Payment',
                        style: const TextStyle(
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
