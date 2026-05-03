import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> rideData;

  const RideDetailsScreen({super.key, required this.rideData});

  @override
  Widget build(BuildContext context) {
    // --- Firebase Data Extraction & Formatting ---

    // Price & Seats
    final int price = rideData['pricePerSeat'] ?? 0;
    final int availableSeats = rideData['availableSeats'] ?? 0;
    final int totalSeats = rideData['totalSeats'] ?? 0;

    // Locations & Stops
    final String startLoc = rideData['fromLocation'] ?? 'Origin';
    final String endLoc = rideData['toLocation'] ?? 'Destination';
    final List stopsArray = rideData['stops'] ?? [];

    // Vehicle Info
    final String vType = rideData['vehicleType'] ?? 'Vehicle';
    final bool hasAC = rideData['hasAC'] ?? false;
    final String vehicleInfo =
        "$vType ride, ${hasAC ? "AC" : "Non-AC"}. You can board/exit at any checkpoint along the route.";

    // Time Formatting (Handling both Timestamp and String safely)
    DateTime departureDt = DateTime.now();
    var departureData = rideData['departureTime'];
    if (departureData != null) {
      if (departureData is Timestamp) {
        departureDt = departureData.toDate();
      } else if (departureData is String) {
        departureDt = DateTime.tryParse(departureData) ?? DateTime.now();
      }
    }

    final String formattedDate = DateFormat(
      'MMMM d, yyyy',
    ).format(departureDt); // Example: May 3, 2026
    final String formattedTime = DateFormat(
      'h:mm a',
    ).format(departureDt); // Example: 7:30 AM

    // Build Dynamic Route Array
    List<Map<String, dynamic>> routeNodes = [];
    routeNodes.add({"name": startLoc, "type": "start"});
    for (var stop in stopsArray) {
      // If your stops are saved as Strings in Firebase
      String stopName = stop is String ? stop : (stop['name'] ?? 'Stop');
      routeNodes.add({"name": stopName, "type": "mid"});
    }
    routeNodes.add({"name": endLoc, "type": "end"});

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button
            InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Back to Search",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header (Ride Details & Badge)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Ride Details",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rideData['status'] ?? "scheduled",
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              "Route",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Dynamic Route Timeline
            _buildDynamicRouteTimeline(routeNodes),

            const SizedBox(height: 20),

            // Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6), // Light yellow
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                "Note: You can board or exit at any checkpoint along this route. Select your preferred pickup and dropoff locations when booking.",
                style: TextStyle(color: Colors.black87, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),

            // Date, Time, Seats Info
            _buildInfoRow(Icons.calendar_today, "Date", formattedDate),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.access_time, "Time", formattedTime),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.people_outline,
              "Available Seats",
              "$availableSeats of $totalSeats",
            ),
            const SizedBox(height: 24),

            // Price Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFFEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.attach_money,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Price per seat",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Text(
                    "৳$price",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Additional Information
            const Text(
              "Additional Information",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                vehicleInfo,
                style: const TextStyle(color: Colors.black87, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),

            // Map Section (Optional - keep static or update later)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.near_me,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Route View",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Check map for details",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A69FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.map, size: 16, color: Colors.white),
                    label: const Text(
                      "Maps",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100), // Bottom padding for fixed button
          ],
        ),
      ),
      // Fixed Book Button at Bottom
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A0F2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Booking Logic Here
            },
            child: const Text(
              "Book This Ride",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D79FF), Color(0xFF00CBA9)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "RideShare",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1A69FF), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDynamicRouteTimeline(List<Map<String, dynamic>> routeNodes) {
    return Column(
      children: List.generate(routeNodes.length, (index) {
        final node = routeNodes[index];
        final bool isLast = index == routeNodes.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side Timeline Nodes
            Column(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF1A69FF),
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(width: 2, height: 50, color: Colors.blue.shade100),
              ],
            ),
            const SizedBox(width: 12),
            // Right Side Location Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50.withAlpha(128),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        node["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (node["type"] == "start")
                      _buildBadge("Start", Colors.green)
                    else if (node["type"] == "end")
                      _buildBadge("End", Colors.red),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBadge(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.shade700,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
