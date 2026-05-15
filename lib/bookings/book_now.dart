import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookRideScreen extends StatefulWidget {
  final String rideId; // List page theke ride-er ID pathate hobe

  const BookRideScreen({super.key, required this.rideId});

  @override
  State<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  int seatCount = 1;
  String selectedPayment = "Cash";
  Map<String, dynamic>? rideData;
  Map<String, dynamic>? driverData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFullDetails();
  }

  // Firestore theke ride ebong driver er details fetch kora
  Future<void> _fetchFullDetails() async {
    try {
      // 1. Rides collection theke data ana
      var rideDoc = await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .get();

      if (rideDoc.exists) {
        rideData = rideDoc.data();
        
        // 2. Driver-er ID use kore users collection theke details ana
        var driverDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(rideData!['driverId'])
            .get();

        if (driverDoc.exists) {
          driverData = driverDoc.data();
        }
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (rideData == null) {
      return const Scaffold(body: Center(child: Text("Ride not found!")));
    }

    // Firebase theke data variables-e nawa
    final String from = rideData!['fromLocation'] ?? "N/A";
    final String to = rideData!['toLocation'] ?? "N/A";
    final int pricePerSeat = rideData!['pricePerSeat'] ?? 0;
    final int availableSeats = rideData!['availableSeats'] ?? 0;
    final double distance = (rideData!['distance'] ?? 0.0).toDouble();
    
    // Time formatting
    DateTime departure = (rideData!['departureTime'] as Timestamp).toDate();
    String formattedTime = DateFormat('dd MMM, h:mm a').format(departure);

    return Scaffold(
      backgroundColor: const Color(0xffF1F4F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Book Your Ride", style: TextStyle(color: Color(0xff2962FF), fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Review and confirm your booking", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Ride Details Section ---
            _buildSectionHeader(Icons.location_on_outlined, "Ride Details"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                children: [
                  _buildRouteInfo(from, to),
                  const SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _buildInfoTile(Icons.access_time, "Departure", formattedTime),
                      _buildInfoTile(Icons.people_outline, "Available", "$availableSeats seat(s)"),
                      _buildInfoTile(Icons.near_me_outlined, "Distance", "$distance km"),
                      _buildInfoTile(Icons.directions_car, "Vehicle", rideData!['vehicleType'] ?? "Car"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Driver Information (Dynamic) ---
            const Text("Driver Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: const Color(0xff2962FF),
                    child: Text(driverData?['fullname']?[0].toUpperCase() ?? "D", style: const TextStyle(color: Colors.white, fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driverData?['fullname'] ?? "Loading...", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Row(
                        children: [
                          Icon(Icons.star, color: Colors.orange, size: 16),
                          Text(" 4.5", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.orange)),
                          Text(" - Active Driver", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Booking Information ---
            _buildSectionHeader(Icons.check_circle_outline, "Booking Information"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Number of Seats *", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCounterBtn(Icons.remove, () => setState(() => seatCount > 1 ? seatCount-- : null)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text("$seatCount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      _buildCounterBtn(Icons.add, () => setState(() => seatCount < availableSeats ? seatCount++ : null)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Contact Number *", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter your phone number",
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Payment Method *", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _paymentTile("Cash", Icons.account_balance_wallet_outlined),
                      _paymentTile("bKash", Icons.smartphone),
                      _paymentTile("Nagad", Icons.move_to_inbox),
                      _paymentTile("Card", Icons.credit_card),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- Summary (Dynamic) ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xff2962FF), Color(0xff6A11CB)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _summaryRow("Price per seat", "Tk $pricePerSeat"),
                  _summaryRow("Seats", "x $seatCount"),
                  const Divider(color: Colors.white30),
                  _summaryRow("Total Amount", "Tk ${pricePerSeat * seatCount}", isTotal: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Confirm Button ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _handleBooking(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2962FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text("Confirm Booking", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Booking confirm kore database-e save kora
  Future<void> _handleBooking() async {
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'rideId': widget.rideId,
        'driverId': rideData!['driverId'],
        'passengerId': 'CURRENT_USER_ID', // FirebaseAuth.instance.currentUser!.uid
        'fromLocation': rideData!['fromLocation'],
        'toLocation': rideData!['toLocation'],
        'seatsBooked': seatCount,
        'totalPrice': (rideData!['pricePerSeat'] ?? 0) * seatCount,
        'status': 'confirmed',
        'paymentMethod': selectedPayment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Booking Confirmed!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- Helper Methods ---
  Widget _buildSectionHeader(IconData icon, String title) => Row(children: [Icon(icon, color: const Color(0xff2962FF), size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]);
  BoxDecoration _cardDecoration() => BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]);
  Widget _buildRouteInfo(String f, String t) => Row(children: [const Column(children: [Icon(Icons.circle, color: Colors.green, size: 14), Icon(Icons.more_vert, color: Colors.grey), Icon(Icons.circle, color: Colors.red, size: 14)]), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(f, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), const SizedBox(height: 15), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))])]);
  Widget _buildInfoTile(IconData i, String l, String v) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(i, size: 16, color: Colors.grey[600]), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l, style: const TextStyle(fontSize: 9, color: Colors.grey)), Text(v, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))]))]));
  Widget _buildCounterBtn(IconData i, VoidCallback o) => GestureDetector(onTap: o, child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)), child: Icon(i, size: 18)));
  Widget _paymentTile(String t, IconData i) { bool s = selectedPayment == t; return GestureDetector(onTap: () => setState(() => selectedPayment = t), child: Container(decoration: BoxDecoration(border: Border.all(color: s ? Colors.green : Colors.grey[200]!), borderRadius: BorderRadius.circular(12), color: s ? Colors.green.withOpacity(0.05) : Colors.white), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, size: 20, color: s ? Colors.green : Colors.grey), Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: s ? Colors.green : Colors.grey))]))); }
  Widget _summaryRow(String t, String v, {bool isTotal = false}) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(t, style: TextStyle(color: Colors.white, fontSize: isTotal ? 18 : 14)), Text(v, style: TextStyle(color: Colors.white, fontSize: isTotal ? 22 : 14, fontWeight: FontWeight.bold))]));
}