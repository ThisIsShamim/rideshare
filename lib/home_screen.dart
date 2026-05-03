import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Time format korar jonno
import 'ride_details_screen.dart'; // ফাইলের নাম আপনার ফাইলের নামের সাথে মিলিয়ে নেবেন
import 'ride_post.dart'; // <-- এই লাইনটি যোগ করুন
import 'profile/profile.dart';
import 'my_rides_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ২. initState এর মাধ্যমে অ্যাপ চালু হলেই আপডেট ফাংশনটি কল হবে
  @override
  void initState() {
    super.initState();
    _updateExpiredRides(); // কল করা হলো
  }

  // ৩. আপডেট করার ফাংশনটি এখানে রাখা হলো
  Future<void> _updateExpiredRides() async {
    try {
      final now = Timestamp.now();
      final snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('status', isEqualTo: 'active')
          .where('departureTime', isLessThanOrEqualTo: now)
          .get();

      if (snapshot.docs.isEmpty) return;

      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'status': 'inactive'});
      }
      await batch.commit();
      debugPrint("Expired rides updated successfully.");
    } catch (e) {
      debugPrint("Error updating expired rides: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          _buildInfoBanner(),
          _buildFilterChips(),
          const SizedBox(height: 10),
          // Real-time Firebase Data List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // ৪. StreamBuilder এ শুধু active রাইডগুলোই দেখানো হবে
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .where('status', isEqualTo: 'active')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching data"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No rides available right now."),
                  );
                }

                final rides = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final doc = rides[index].data() as Map<String, dynamic>;
                    return _buildRideCard(
                      context,
                      doc,
                    ); // আপনার আগের _buildRideCard এখানে থাকবে
                  },
                );
              },
            ),
          ),
        ],
      ),
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
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- App Bar ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            backgroundColor: Color(0xFF1A69FF),
            child: Text(
              "A",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Find a Ride",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                "Real-time rides available",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            icon: const Icon(Icons.tune, size: 16, color: Colors.black),
            label: const Text("Filters", style: TextStyle(color: Colors.black)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.grey, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "Female Only rides are hidden from your results for safety.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildChip("Soonest", Icons.access_time, isSelected: true),
          _buildChip("Cheapest", Icons.local_offer_outlined),
          _buildChip("Top Rated", Icons.star_border),
          _buildChip("Car", Icons.directions_car_outlined),
          _buildChip("Bike", Icons.two_wheeler),
          _buildChip("AC", Icons.ac_unit),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A69FF) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF1A69FF) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // --- Firebase Data Mapping ---
  Widget _buildRideCard(BuildContext context, Map<String, dynamic> doc) {
    // Exact mapping based on your Firebase structure
    final int price = doc['pricePerSeat'] ?? 0;
    final String startLoc = doc['fromLocation'] ?? 'Unknown';
    final String endLoc = doc['toLocation'] ?? 'Unknown';
    final int seatsLeft = doc['availableSeats'] ?? 0;

    // Vehicle string building
    final String vColor = doc['vehicleColor'] ?? '';
    final String vModel = doc['vehicleModel'] ?? '';
    final String vehicleInfo = "$vColor $vModel".trim();

    // Stops count calculation
    final List stopsArray = doc['stops'] ?? [];
    final int stopsCount = stopsArray.length;

    // --- Time Formatting Section ---
    String formattedTime = 'TBA';
    var departureData = doc['departureTime'];

    if (departureData != null) {
      DateTime dt;
      if (departureData is Timestamp) {
        dt = departureData.toDate();
      } else if (departureData is String) {
        dt = DateTime.tryParse(departureData) ?? DateTime.now();
      } else {
        dt = DateTime.now();
      }
      formattedTime = DateFormat('dd MMM - h:mm a').format(dt);
    }

    // Driver ID (ফায়ারবেস থেকে নাম আনার জন্য)
    final String driverId = doc['driverId'] ?? '';

    // Static values for now (যেহেতু রেটিং এবং টোটাল রাইড ফায়ারবেসে নেই)
    const double rating = 4.8;
    const int totalRides = 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Dynamic Header Section with FutureBuilder ---
          FutureBuilder<QuerySnapshot>(
            future: driverId.isNotEmpty
                ? FirebaseFirestore.instance
                      .collection('users')
                      .where(
                        'uid',
                        isEqualTo: driverId,
                      ) // users কালেকশনে uid খুঁজবে
                      .limit(1)
                      .get()
                : null,
            builder: (context, snapshot) {
              String driverName = "Loading...";
              String? profilePic;

              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  var userData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  driverName = userData['fullname'] ?? 'Unknown User';
                  profilePic = userData['profilePicture'];
                } else {
                  driverName = "Not Found";
                }
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF1A69FF),
                        radius: 20,
                        backgroundImage: profilePic != null
                            ? NetworkImage(profilePic)
                            : null,
                        child: profilePic == null
                            ? Text(
                                driverName.isNotEmpty &&
                                        driverName != "Loading..." &&
                                        driverName != "Not Found"
                                    ? driverName[0]
                                          .toUpperCase() // নামের প্রথম অক্ষর
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- ইউজারের আসল নাম এবং ভেরিফাইড আইকন ---
                          Row(
                            children: [
                              Text(
                                driverName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 16,
                              ),
                            ],
                          ),
                          // --- রেটিং সেকশন ---
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 14),
                              SizedBox(width: 4),
                              Text(
                                "$rating",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                " · $totalRides rides",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "৳$price",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        "per seat",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // --- Route Section ---
          Row(
            children: [
              Column(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 10),
                  Container(height: 20, width: 2, color: Colors.grey.shade300),
                  const Icon(Icons.circle, color: Colors.red, size: 10),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(startLoc, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 12),
                    Text(
                      endLoc,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (stopsCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$stopsCount stops",
                    style: const TextStyle(
                      color: Color(0xFF1A69FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Info Tags ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoTag(Icons.access_time, formattedTime),
              _buildInfoTag(
                Icons.people_outline,
                "$seatsLeft seat left",
                textColor: const Color(0xFF1A69FF),
              ),
              _buildInfoTag(Icons.directions_car, vehicleInfo),
              if (doc['hasAC'] == true) _buildInfoTag(Icons.ac_unit, "AC"),
            ],
          ),
          const SizedBox(height: 16),

          // --- Action Buttons ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Map<String, dynamic> rideDataMap = doc;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RideDetailsScreen(rideData: rideDataMap),
                      ),
                    );
                  },
                  child: const Text(
                    "Details >",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A69FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.book_online,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    "Book Now",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTag(
    IconData icon,
    String text, {
    Color textColor = Colors.black54,
  }) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Search", true, () {}),
            _buildNavItem(Icons.format_list_bulleted, "Rides", false, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyRidesScreen()),
              );
            }),
            // Profile এ ক্লিক করলে নেভিগেট হবে
            _buildNavItem(Icons.person_outline, "Profile", false, () {
              // Profile স্ক্রিনে যাওয়ার জন্য Navigator যোগ করা হলো
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfileScreen(), // আপনার profile.dart এর ক্লাসের নাম যদি ভিন্ন হয়, তবে সেটা এখানে দিন
                ),
              );
            }),

            _buildNavItem(Icons.more_horiz, "More", false, () {}),
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
