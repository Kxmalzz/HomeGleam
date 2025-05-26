import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'work_selection.dart'; // Ensure this has WorkModel

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> provider;
  final DateTime date;
  final TimeOfDay time;
  final List<WorkModel> selectedWorks;
  final List<int> selectedExtraCleaning;
  final int selectedRepeat;

  const PaymentPage({
    Key? key,
    required this.provider,
    required this.date,
    required this.time,
    required this.selectedWorks,
    required this.selectedExtraCleaning,
    required this.selectedRepeat,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedPaymentMethod = 0;
  bool _paymentSuccess = false;
  double totalAmount = 0.0;
  final TextEditingController _cardController = TextEditingController();

  final List<Map<String, dynamic>> _paymentMethods = [
    {"icon": Icons.account_balance_wallet, "name": "UPI"},
    {"icon": Icons.credit_card, "name": "Credit/Debit Card"},
    {"icon": Icons.attach_money, "name": "Cash on Service"},
  ];

  final List<String> extraCleaningOptions = [
    "Washing",
    "Fridge",
    "Oven",
    "Window Cleaning"
  ];

  @override
  void initState() {
    super.initState();
    calculateTotalAmount();
  }

  void calculateTotalAmount() {
    final Map<String, double> workCosts = {
      'Living Room Cleaning': 15,
      'Bedroom Cleaning': 150,
      'Bathroom Cleaning': 120,
      'Kitchen Cleaning': 130,
      'Office Room Cleaning': 200,
      'Vessel Washing': 80,
      'Cooking': 250,
      'Babysitting': 300,
    };

    double baseTotal = widget.selectedWorks.fold(0.0, (sum, work) {
      double cost = workCosts[work.name] ?? 0;
      return sum + (cost * work.count);
    });

    double extraCost = widget.selectedExtraCleaning.length * 50;

    int multiplier;
    switch (widget.selectedRepeat) {
      case 1:
        multiplier = 30; // Everyday
        break;
      case 2:
        multiplier = 4; // Weekly
        break;
      case 3:
        multiplier = 1; // Monthly
        break;
      default:
        multiplier = 1; // No repeat
    }

    setState(() {
      totalAmount = (baseTotal + extraCost) * multiplier;
    });
  }

  void _confirmPayment() async {
    if (_selectedPaymentMethod == 1 &&
        (_cardController.text.length != 16 ||
            !_cardController.text.contains(RegExp(r'^\d{16}$')))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 16-digit card number")),
      );
      return;
    }

    // Mock payment processing - replace this with your actual payment integration
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay

    setState(() {
      _paymentSuccess = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment Successful!")),
    );
  }

  void _printReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Printing Receipt...")),
    );
  }

  void _downloadReceipt() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading Receipt...")),
    );
  }

  String _getRepeatText(int repeat) {
    switch (repeat) {
      case 0:
        return "No Repeat";
      case 1:
        return "Everyday";
      case 2:
        return "Every Week";
      case 3:
        return "Every Month";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(widget.date);
    final formattedTime = widget.time.format(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Service Provider: ${widget.provider['name']}",
                style: const TextStyle(fontSize: 16)),
            Text("Date: $formattedDate", style: const TextStyle(fontSize: 16)),
            Text("Time: $formattedTime", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              "Selected Works: ${widget.selectedWorks.map((e) => e.name).join(', ')}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Extra Cleaning: ${widget.selectedExtraCleaning.map((i) => extraCleaningOptions[i]).join(', ')}",
              style: const TextStyle(fontSize: 16),
            ),
            Text("Repeat: ${_getRepeatText(widget.selectedRepeat)}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            const Text("Total Amount",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("₹${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 30),
            const Text("Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),
            Column(
              children: List.generate(_paymentMethods.length, (index) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: Icon(_paymentMethods[index]["icon"],
                        color: Colors.blueAccent),
                    title: Text(_paymentMethods[index]["name"]),
                    trailing: Radio(
                      value: index,
                      groupValue: _selectedPaymentMethod,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (_selectedPaymentMethod == 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter the upi Number",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cardController,
                    maxLength: 16,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "UPI ID",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            if (_selectedPaymentMethod == 1)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Enter 16-digit Card Number",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cardController,
                    maxLength: 16,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "XXXX XXXX XXXX",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
            if (!_paymentSuccess)
              Center(
                child: ElevatedButton(
                  onPressed: _confirmPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Proceed to Pay",
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            if (_paymentSuccess)
              Column(
                children: [
                  const Text("Payment Successful!",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _printReceipt,
                        icon: const Icon(Icons.print),
                        label: const Text("Print Receipt"),
                      ),
                      ElevatedButton.icon(
                        onPressed: _downloadReceipt,
                        icon: const Icon(Icons.download),
                        label: const Text("Download Receipt"),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
