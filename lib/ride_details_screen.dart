import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ride_post.dart';
import 'profile/profile.dart';
import 'my_rides_screen.dart';
import 'request_ride/request_ride_screen.dart';
import 'fetch_data/user_service.dart'; // <-- UserService Import করা হলো

class RideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> rideData;

  const RideDetailsScreen({super.key, required this.rideData});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // --- Home Screen এর App Bar ---
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back to Search Button
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.black87),
                  SizedBox(width: 8),
                  Text(
                    'Back to Search',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // আপনার দেওয়া ডিজাইন করা কন্টেইনার
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainDetails(),
                  const Divider(height: 1, thickness: 1),
                  _buildDriverInformation(),
                  const Divider(height: 1, thickness: 1),
                  _buildVehicleDetails(),
                ],
              ),
            ),
            const SizedBox(height: 80), // Bottom Bar এর জন্য ফাঁকা জায়গা
          ],
        ),
      ),
      // --- Home Screen এর Floating Action Button ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A69FF),
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostARideScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // --- Home Screen এর Bottom Navigation Bar ---
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- 1. Main Details (Location, Price, Time) ---
  Widget _buildMainDetails() {
    final ride = widget.rideData;
    final int price = ride['pricePerSeat'] ?? 0;
    final String startLoc = ride['fromLocation'] ?? 'Unknown Location';
    final String endLoc = ride['toLocation'] ?? 'Unknown Location';
    final int availableSeats = ride['availableSeats'] ?? 0;
    final bool isFemaleOnly = ride['isFemaleOnly'] ?? false;

    // সময় ঠিক করা
    String formattedTime = 'TBA';
    var departureData = ride['departureTime'];
    if (departureData != null) {
      DateTime dt;
      if (departureData is Timestamp) {
        dt = departureData.toDate();
      } else if (departureData is String) {
        dt = DateTime.tryParse(departureData) ?? DateTime.now();
      } else {
        dt = DateTime.now();
      }
      formattedTime = DateFormat('dd MMM yyyy, h:mm a').format(dt);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ride Route",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (isFemaleOnly)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.pink.shade200),
                  ),
                  child: const Text(
                    "Female Only",
                    style: TextStyle(
                      color: Colors.pink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.my_location, "From", startLoc),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on, "To", endLoc),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.access_time, "Departure", formattedTime),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVehicleInfoCol("Price", "৳$price per seat"),
              _buildVehicleInfoCol(
                "Available Seats",
                "$availableSeats seats left",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 2. Driver Information (Firebase Database থেকে) ---
  Widget _buildDriverInformation() {
    final driverId = widget.rideData['driverId'] ?? '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Driver Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<Map<String, String?>>(
            future: driverId.isNotEmpty
                ? _userService.getDriverInfo(driverId)
                : null,
            builder: (context, snapshot) {
              String driverName = "Loading...";
              String? profilePic;

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  driverName = snapshot.data!['name'] ?? 'Unknown Driver';
                  profilePic = snapshot.data!['photoUrl'];
                } else {
                  driverName = "Not Found";
                }
              }

              return Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: profilePic != null
                        ? NetworkImage(profilePic)
                        : null,
                    child: profilePic == null
                        ? Text(
                            driverName != "Loading..." &&
                                    driverName != "Not Found"
                                ? driverName[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "4.8 (15 reviews)", // আপনি চাইলে এটিও ডাইনামিক করতে পারেন
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.message, color: Color(0xFF1A69FF)),
                    onPressed: () {
                      // Message functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: Colors.green),
                    onPressed: () {
                      // Call functionality
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- 3. Vehicle Details ---
  Widget _buildVehicleDetails() {
    final ride = widget.rideData;
    final String vModel = ride['vehicleModel'] ?? 'Unknown Model';
    final String vColor = ride['vehicleColor'] ?? 'Unknown Color';
    final String vPlate = ride['vehiclePlate'] ?? 'Not Provided';
    final bool hasAC = ride['hasAC'] ?? false;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vehicle Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildVehicleInfoCol("Model", vModel),
              _buildVehicleInfoCol("Color", vColor),
              _buildVehicleInfoCol("AC", hasAC ? "Yes" : "No"),
            ],
          ),
          const SizedBox(height: 12),
          _buildContactRow(Icons.directions_car, "License Plate: $vPlate"),
          const SizedBox(height: 20),

          // Book Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A69FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Book Now action
              },
              child: const Text(
                "Book Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue[400], size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
      ],
    );
  }

  Widget _buildVehicleInfoCol(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.blue[400], fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- App Bar ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D79FF), Color(0xFF00CBA9)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'sans-serif',
              ),
              children: [
                TextSpan(
                  text: "Ride",
                  style: TextStyle(color: Color(0xFF1D2127)),
                ),
                TextSpan(
                  text: "Share",
                  style: TextStyle(color: Color(0xFF00B14F)),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF5F6368), size: 26),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Color(0xFF5F6368),
            size: 26,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF5F6368), size: 26),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // --- Bottom Navigation Bar ---
  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      elevation: 15,
      shadowColor: Colors.black45,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, "Search", false, () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }),
                  _buildNavItem(Icons.format_list_bulleted, "Rides", false, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyRidesScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Post',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                const SizedBox(height: 4),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.inbox_outlined, "Requests", false, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RequestRideScreen(),
                      ),
                    );
                  }),
                  _buildNavItem(Icons.person_outline, "Profile", false, () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1A69FF) : Colors.grey,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1A69FF) : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
