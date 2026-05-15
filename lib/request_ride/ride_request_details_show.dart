import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RideRequestDetailsShow extends StatefulWidget {
  // ১. এই লাইনটি অ্যাড করুন
  final VoidCallback? onBackPressed;

  // ২. কনস্ট্রাকটরে এটি পাস করুন
  const RideRequestDetailsShow({Key? key, this.onBackPressed})
    : super(key: key);

  @override
  State<RideRequestDetailsShow> createState() => _RideRequestDetailsShowState();
}

class _RideRequestDetailsShowState extends State<RideRequestDetailsShow> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ["All", "Pending", "Accepted", "Declined"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabs(),
            const SizedBox(height: 16),
            Expanded(
              // Firebase StreamBuilder ekhane
              child: StreamBuilder<QuerySnapshot>(
                // Apni chaile .where('userId', isEqualTo: widget.currentUserId) add korte paren
                stream: FirebaseFirestore.instance
                    .collection('ride_request')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading data"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Data ashar por list nilam
                  var allRequests = snapshot.data?.docs ?? [];

                  // Tab onujayi data filter kora
                  var filteredRequests = allRequests.where((doc) {
                    if (_selectedTabIndex == 0) return true; // All

                    String status = doc['status'].toString().toLowerCase();
                    if (_selectedTabIndex == 1 && status == 'pending')
                      return true;
                    if (_selectedTabIndex == 2 && status == 'accepted')
                      return true;
                    if (_selectedTabIndex == 3 && status == 'declined')
                      return true;

                    return false;
                  }).toList();

                  if (filteredRequests.isEmpty) {
                    return const Center(
                      child: Text(
                        "No ride requests found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      var docData =
                          filteredRequests[index].data()
                              as Map<String, dynamic>;
                      String docId = filteredRequests[index].id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildRideCard(docId, docData),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... _buildHeader() ebong _buildTabs() aager motoy thakbe ...
  // (Space bachanor jonno ekhane skip korlam, apni aager code theke nite parben.
  // Shudhu tab er nam theke count soraye diyechen jate dynamic vabe data ashe)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () {
                    // ৩. এখানে লজিক চেঞ্জ করা হলো
                    if (widget.onBackPressed != null) {
                      widget.onBackPressed!(); // Home Screen-এ ব্যাক করার জন্য
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Ride Requests",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.send, size: 16),
            label: const Text(
              "New",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedTabIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue.shade600
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Dynamic Card Widget
  Widget _buildRideCard(String docId, Map<String, dynamic> data) {
    // Firebase theke data nilam
    String pickup = data['pickup_location'] ?? 'Unknown';
    String dropoff = data['dropoff_location'] ?? 'Unknown';
    int price = data['max_price'] ?? 0;
    int passengers = data['passengers'] ?? 1;
    String status = data['status'] ?? 'pending';
    String notes = data['notes'] ?? '';

    // Date Time Formatting
    DateTime createdAt = (data['created_at'] as Timestamp).toDate();
    DateTime rideTime = (data['ride_time'] as Timestamp).toDate();

    String formattedCreatedAt = DateFormat('MMM d, h:mm a').format(createdAt);
    String formattedRideDate = DateFormat('MMM d').format(rideTime);
    String formattedRideTime = DateFormat('h:mm a').format(rideTime);

    // Status onujayi UI color
    Color headerColor = Colors.orange.shade500;
    String statusText = "Waiting for driver";
    IconData statusIcon = Icons.hourglass_bottom;

    if (status == 'accepted') {
      headerColor = Colors.green.shade600;
      statusText = "Ride Accepted";
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'declined') {
      headerColor = Colors.red.shade500;
      statusText = "Ride Declined";
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: headerColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dynamic Header Color & Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedCreatedAt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dynamic Locations
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pickup,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dropoff,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Dynamic Info Boxes
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        Icons.access_time,
                        formattedRideDate,
                        formattedRideTime,
                        Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBox(
                        Icons.people_outline,
                        "$passengers",
                        "seats",
                        Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBox(
                        Icons.payments_outlined,
                        "৳$price",
                        "max",
                        Colors.green.shade50,
                        iconColor: Colors.teal,
                      ),
                    ),
                  ],
                ),

                // Dynamic Notes (Jodi notes faka na thake taholei dekhabe)
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      notes,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Cancel Button (Shudhu pending thaklei cancel kora jabe)
                if (status == 'pending')
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Cancel logic ekhane add korun
                        // FirebaseFirestore.instance.collection('ride_request').doc(docId).update({'status': 'declined'});
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        "Cancel Request",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor, {
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: iconColor != null ? Colors.teal.shade800 : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: iconColor != null
                  ? Colors.teal.shade600
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
