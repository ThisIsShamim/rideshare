import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  bool isDriverSelected = true;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  @override
  Widget build(BuildContext context) {
    // Dynamic Query selection
    final Query rideQuery = isDriverSelected
        ? FirebaseFirestore.instance
              .collection('rides')
              .where('driverId', isEqualTo: currentUserId)
        : FirebaseFirestore.instance
              .collection('bookings')
              .where('passengerId', isEqualTo: currentUserId);

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildToggleTab(),
              const SizedBox(height: 20),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: rideQuery.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        var data =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;
                        return _buildRideCard(data);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Ride Card UI ---
  Widget _buildRideCard(Map<String, dynamic> data) {
    // Firebase field names handling
    DateTime departure = (data['departureTime'] as Timestamp).toDate();
    String formattedTime = DateFormat('jm').format(departure);
    String formattedDate = DateFormat('MMMM d').format(departure);

    // Bookings collection e 'totalPrice' thake, Rides e 'pricePerSeat'
    String price = isDriverSelected
        ? "${data['pricePerSeat']} BDT/Seat"
        : "${data['totalPrice']} BDT Total";

    // Bookings collection e 'seatsBooked' thake, Rides e 'availableSeats'
    String seatInfo = isDriverSelected
        ? "${data['availableSeats']}/${data['totalSeats']} Available"
        : "${data['seatsBooked']} Seats Booked";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  color: Color(0xff2962FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (data['status'] == 'active' ||
                          data['paymentStatus'] == 'paid')
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (isDriverSelected ? data['status'] : data['paymentStatus'])
                      .toString()
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        (data['status'] == 'active' ||
                            data['paymentStatus'] == 'paid')
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, size: 12, color: Colors.blue),
                  Container(height: 30, width: 2, color: Colors.grey[200]),
                  const Icon(
                    Icons.location_on,
                    size: 14,
                    color: Colors.redAccent,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['fromLocation'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      data['toLocation'] ?? "Unknown",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    price,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 30, thickness: 0.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isDriverSelected
                        ? Icons.airline_seat_recline_normal
                        : Icons.person_pin,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    seatInfo,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
              // Passenger tab e Driver name dekhano
              if (!isDriverSelected)
                Text(
                  "Driver: ${data['driverName']}",
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- UI Helpers ---
  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            "My Rides",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        if (isDriverSelected)
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff2962FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Post Ride",
              style: TextStyle(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildToggleTab() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xffECECEC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _tabButton(
            "Driver",
            Icons.directions_car_outlined,
            isDriverSelected,
            () => setState(() => isDriverSelected = true),
          ),
          _tabButton(
            "Passenger",
            Icons.person_outline,
            !isDriverSelected,
            () => setState(() => isDriverSelected = false),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xff2962FF) : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.car_rental_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            isDriverSelected ? "No rides posted" : "No bookings found",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            isDriverSelected
                ? "Post a ride to see it here"
                : "Book a ride to see it here",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
