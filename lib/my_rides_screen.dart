import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final Color appPrimaryColor = Colors.blue; // Apnar app-er main color

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white for clean look
      appBar: AppBar(
        backgroundColor: appPrimaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Rides",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "As Driver"),
            Tab(text: "As Passenger"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRideList(isDriver: true),
          _buildRideList(isDriver: false),
        ],
      ),
    );
  }

  Widget _buildRideList({required bool isDriver}) {
    Query query = FirebaseFirestore.instance.collection('rides');

    if (isDriver) {
      query = query.where('driverId', isEqualTo: userId);
    } else {
      // Note: Make sure 'passengerIds' array exists in your DB for booked rides
      query = query.where('passengerIds', arrayContains: userId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: appPrimaryColor),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(isDriver);
        }

        // Local Sorting (Safe way to avoid Firebase Index error)
        var docs = snapshot.data!.docs.toList();
        docs.sort((a, b) {
          var timeA =
              (a.data() as Map<String, dynamic>)['departureTime'] as Timestamp?;
          var timeB =
              (b.data() as Map<String, dynamic>)['departureTime'] as Timestamp?;
          if (timeA == null || timeB == null) return 0;
          return timeB.compareTo(timeA);
        });

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var ride = docs[index].data() as Map<String, dynamic>;
            return _buildSimpleRideCard(ride);
          },
        );
      },
    );
  }

  Widget _buildSimpleRideCard(Map<String, dynamic> ride) {
    // Data Extraction
    String from = ride['fromLocation'] ?? 'Unknown';
    String to = ride['toLocation'] ?? 'Unknown';
    String price = ride['pricePerSeat']?.toString() ?? '0';
    String status = ride['status'] ?? 'active';

    String timeText = "";
    if (ride['departureTime'] is Timestamp) {
      timeText = DateFormat(
        'dd MMM, hh:mm a',
      ).format((ride['departureTime'] as Timestamp).toDate());
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Date & Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "৳$price/seat",
                  style: TextStyle(
                    color: appPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Locations
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: appPrimaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(from, style: const TextStyle(fontSize: 15)),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: SizedBox(
                height: 10,
                child: VerticalDivider(width: 2, thickness: 1),
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(to, style: const TextStyle(fontSize: 15))),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: appPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: appPrimaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  "Seats: ${ride['availableSeats']}/${ride['totalSeats']}",
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDriver) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            isDriver ? "No rides posted" : "No rides booked",
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
