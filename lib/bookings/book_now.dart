import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookRideScreen extends StatefulWidget {
  final String rideId;

  const BookRideScreen({super.key, required this.rideId});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  int _seatsToBook = 1;
  bool _isBooking = false;
  String _selectedPaymentMethod = "Cash"; // Default selection

  // এই ভেরিয়েবলটি ডাটা একবার ফেচ করে সেভ করে রাখবে
  late Future<DocumentSnapshot> _rideFuture;

  // Premium UI Color Palette
  final Color primaryColor = const Color(0xFF1A69FF);
  final Color secondaryColor = const Color(0xFF0A1931);
  final Color backgroundColor = const Color(0xFFF9FAFC);
  final Color cardColor = Colors.white;

  // Payment Methods Configuration List
  final List<Map<String, dynamic>> _paymentMethods = [
    {"id": "Cash", "title": "Cash on Ride", "icon": Icons.payments_rounded},
    {
      "id": "bKash",
      "title": "bKash Wallet",
      "icon": Icons.account_balance_wallet_rounded,
    },
    {"id": "Nagad", "title": "Nagad Wallet", "icon": Icons.wallet_rounded},
  ];

  @override
  void initState() {
    super.initState();
    // initState-এর ভেতরে Future কল করলে এটি মাত্র একবারই রান হবে
    _rideFuture = FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.rideId)
        .get();
  }

  Future<void> _confirmBookingTransaction({
    required Map<String, dynamic> rideData,
  }) async {
    setState(() => _isBooking = true);

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? "UNKNOWN_USER";
    final DocumentReference rideRef = firestore
        .collection('rides')
        .doc(widget.rideId);
    final DocumentReference bookingRef = firestore.collection('bookings').doc();

    try {
      await firestore.runTransaction((transaction) async {
        DocumentSnapshot rideSnapshot = await transaction.get(rideRef);

        if (!rideSnapshot.exists) {
          throw Exception("The requested ride could not be found!");
        }

        int currentAvailableSeats = rideSnapshot['availableSeats'] ?? 0;

        if (currentAvailableSeats < _seatsToBook) {
          throw Exception(
            "Not enough seats available! Only $currentAvailableSeats seats are left.",
          );
        }

        int newAvailableSeats = currentAvailableSeats - _seatsToBook;
        int pricePerSeat = rideSnapshot['pricePerSeat'] ?? 0;
        int totalPrice = _seatsToBook * pricePerSeat;

        transaction.update(rideRef, {
          'availableSeats': newAvailableSeats,
          if (newAvailableSeats == 0) 'status': 'inactive',
        });

        transaction.set(bookingRef, {
          'createdAt': FieldValue.serverTimestamp(),
          'driverId': rideSnapshot['driverId'] ?? '',
          'fromLocation': rideSnapshot['fromLocation'] ?? '',
          'passengerId': currentUserId,
          'paymentMethod': _selectedPaymentMethod,
          'rideId': widget.rideId,
          'seatsBooked': _seatsToBook,
          'status': 'confirmed',
          'toLocation': rideSnapshot['toLocation'] ?? '',
          'totalPrice': totalPrice,
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Booking confirmed successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString().replaceAll("Exception: ", ""));
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text(
              "Booking Failed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "OK",
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Confirm Booking",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: cardColor,
        foregroundColor: secondaryColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.withOpacity(0.15), height: 1.0),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // এখানে সরাসরি কল করার বদলে আমরা _rideFuture ভেরিয়েবলটি ব্যবহার করেছি
        future: _rideFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Ride details are missing or unavailable.",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
            );
          }

          final rideData = snapshot.data!.data() as Map<String, dynamic>;
          int maxAvailableSeats = rideData['availableSeats'] ?? 0;
          int pricePerSeat = rideData['pricePerSeat'] ?? 0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Premium Ride Timeline Card
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "RIDE ROUTE",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[400],
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.radio_button_checked_rounded,
                                      color: primaryColor,
                                      size: 20,
                                    ),
                                    Container(
                                      width: 2,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withOpacity(0.5),
                                            Colors.redAccent.withOpacity(0.5),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.redAccent,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pickup Location",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rideData['fromLocation'] ??
                                            'Unknown Start',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      Text(
                                        "Dropoff Location",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        rideData['toLocation'] ??
                                            'Unknown Destination',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Divider(height: 1, thickness: 0.8),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildInfoChip(
                                  Icons.airline_seat_recline_normal_rounded,
                                  "$maxAvailableSeats Seats Left",
                                  Colors.amber[50]!,
                                  Colors.amber[800]!,
                                ),
                                _buildInfoChip(
                                  Icons.ac_unit_rounded,
                                  rideData['hasAC'] == true
                                      ? "AC Vehicle"
                                      : "Non-AC Vehicle",
                                  rideData['hasAC'] == true
                                      ? Colors.blue[50]!
                                      : Colors.grey[100]!,
                                  rideData['hasAC'] == true
                                      ? Colors.blue[700]!
                                      : Colors.grey[600]!,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2. Interactive Seat Count Selector
                      Text(
                        "SELECT SEATS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Number of Seats",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Price per seat remains constant",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  _buildCounterButton(
                                    icon: Icons.remove_rounded,
                                    onPressed: _seatsToBook > 1
                                        ? () => setState(() => _seatsToBook--)
                                        : null,
                                  ),
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "$_seatsToBook",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: secondaryColor,
                                      ),
                                    ),
                                  ),
                                  _buildCounterButton(
                                    icon: Icons.add_rounded,
                                    onPressed: _seatsToBook < maxAvailableSeats
                                        ? () => setState(() => _seatsToBook++)
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Payment Method Section
                      Text(
                        "SELECT PAYMENT METHOD",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _paymentMethods.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final bool isSelected =
                              _selectedPaymentMethod == method['id'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPaymentMethod = method['id'] as String;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey.withOpacity(0.15),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: primaryColor.withOpacity(0.04),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? primaryColor.withOpacity(0.1)
                                          : backgroundColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      method['icon'] as IconData,
                                      color: isSelected
                                          ? primaryColor
                                          : Colors.grey[600],
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      method['title'] as String,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? secondaryColor
                                            : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.grey[300],
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // 4. Invoice Breakdown Section
                      Text(
                        "PRICE SUMMARY",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.grey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildPriceRow(
                              "Seat Fare (৳$pricePerSeat × $_seatsToBook)",
                              "৳${_seatsToBook * pricePerSeat}",
                            ),
                            const SizedBox(height: 12),
                            _buildPriceRow("Booking Fee", "FREE", isFree: true),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: _DashedDivider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total Payable",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: secondaryColor,
                                  ),
                                ),
                                Text(
                                  "৳${_seatsToBook * pricePerSeat}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 5. Fixed Premium Action Footer Panel
              Container(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 34,
                  top: 20,
                ),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Cost",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "৳${_seatsToBook * pricePerSeat}",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isBooking || maxAvailableSeats == 0
                              ? null
                              : () => _confirmBookingTransaction(
                                  rideData: rideData,
                                ),
                          child: _isBooking
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Confirm Booking",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final bool isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled ? Colors.white : Colors.grey[200],
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isEnabled ? primaryColor : Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    IconData icon,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String title, String amount, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isFree ? Colors.green[600] : secondaryColor,
          ),
        ),
      ],
    );
  }
}

// Custom Painter for a Clean Dashed Line
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashHeight = 1.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return const SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
              ),
            );
          }),
        );
      },
    );
  }
}
