import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'ride_details_screen.dart';
import 'ride_post.dart';
import 'my_rides_screen.dart';
import 'request_ride/request_ride_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'fetch_data/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showFilters = true;
  int _selectedIndex = 0; // বর্তমানে কোন ট্যাব সিলেক্টেড তা ট্র্যাক করবে
  String? _userGender;
  bool _isLoadingGender = true;

  // UserService এর অবজেক্ট তৈরি করা হলো
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _updateExpiredRides();
    _fetchUserGender();
  }

  // UserService ব্যবহার করে Gender Fetch করা হচ্ছে
  Future<void> _fetchUserGender() async {
    try {
      auth.User? currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _userService.getUserData(currentUser.uid);
        if (userData != null) {
          setState(() {
            _userGender = userData['gender']?.toString().toLowerCase();
            _isLoadingGender = false;
          });
        } else {
          setState(() => _isLoadingGender = false);
        }
      } else {
        setState(() => _isLoadingGender = false);
      }
    } catch (e) {
      print("Error fetching gender: $e");
      setState(() => _isLoadingGender = false);
    }
  }

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
      body: _buildBodyContent(),
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

  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildSearchContent();
      case 1:
        return _buildMyRidesContent();
      case 2:
        return _buildRequestsContent();
      case 3:
        return _buildProfileContent();
      default:
        return _buildSearchContent();
    }
  }

  Widget _buildSearchContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(),
          _buildActionAndFilterSection(),
          const SizedBox(height: 10),

          // Female User der jonno special banner
          if (!_isLoadingGender &&
              (_userGender == 'female' || _userGender == 'f'))
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.female, color: Colors.pink, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Exclusive Female Only Rides are available for you. Check them out!",
                        style: TextStyle(
                          color: Colors.pink.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Real-time Firebase Data List
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rides')
                .where('status', isEqualTo: 'active')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error fetching data"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("No rides available right now."),
                  ),
                );
              }

              final rides = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final doc = rides[index].data() as Map<String, dynamic>;
                  return _buildRideCard(context, doc);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMyRidesContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "My Rides",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('rides')
                .where(
                  'userId',
                  isEqualTo: auth.FirebaseAuth.instance.currentUser?.uid,
                )
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(child: Text("Error loading rides"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text("You haven't posted any rides yet."),
                  ),
                );
              }

              final rides = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  final doc = rides[index].data() as Map<String, dynamic>;
                  return _buildRideCard(context, doc);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ride Requests",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No ride requests yet."),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
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

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
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
                "1 ride available",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                icon: const Icon(Icons.tune, size: 16, color: Colors.black87),
                label: const Text(
                  "Filters",
                  style: TextStyle(color: Colors.black87),
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "2",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionAndFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestRideScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: _buildActionCard(
                      color: const Color(0xFF1C54F2),
                      icon: Icons.near_me_outlined,
                      title: "Request\na Ride",
                      subtitle: "Find drivers\nnearby",
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    color: const Color(0xFF0F9D58),
                    icon: Icons.list_alt,
                    title: "My Requests",
                    subtitle: "Track your\nrequests",
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (!_isLoadingGender &&
              (_userGender == 'female' || _userGender == 'f')) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      "Female Only rides are hidden from your results for safety.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(
                label: "Soonest",
                icon: Icons.schedule,
                isSelected: false,
              ),
              _buildChip(
                label: "Cheapest",
                icon: Icons.savings_outlined,
                isSelected: false,
              ),
              _buildChip(
                label: "Top Rated",
                icon: Icons.star,
                isSelected: true,
                iconColor: Colors.amber,
              ),
              _buildChip(
                label: "Car",
                icon: Icons.directions_car,
                isSelected: true,
                iconColor: Colors.redAccent,
              ),
              _buildChip(
                label: "Bike",
                icon: Icons.motorcycle,
                isSelected: false,
                iconColor: Colors.redAccent,
              ),
              _buildChip(
                label: "AC",
                icon: Icons.ac_unit,
                isSelected: false,
                iconColor: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1C54F2) : Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF1C54F2) : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --- Updated Ride Card ---
  Widget _buildRideCard(BuildContext context, Map<String, dynamic> doc) {
    final int price = doc['pricePerSeat'] ?? 0;
    final String startLoc = doc['fromLocation'] ?? 'Unknown';
    final String endLoc = doc['toLocation'] ?? 'Unknown';
    final int seatsLeft = doc['availableSeats'] ?? 0;
    final bool isFemaleOnly = doc['isFemaleOnly'] ?? false;

    // ১. Firebase থেকে Distance ফেচ করা হচ্ছে
    // আপনার ডাটাবেসে ফিল্ডের নাম 'distance' হতে হবে (যেমন: "12")
    final String distance = doc['distance']?.toString() ?? '--';

    final String vColor = doc['vehicleColor'] ?? '';
    final String vModel = doc['vehicleModel'] ?? '';
    final String vehicleInfo = "$vColor $vModel".trim();

    final List stopsArray = doc['stops'] ?? [];
    final int stopsCount = stopsArray.length;

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

    final String driverId = doc['driverId'] ?? '';
    const double rating = 4.8;
    const int totalRides = 15;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- মূল কার্ডের কন্টেন্ট ---
            Padding(
              padding: EdgeInsets.fromLTRB(16, isFemaleOnly ? 28 : 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Driver Info Section ---
                  FutureBuilder<Map<String, String?>>(
                    future: driverId.isNotEmpty
                        ? _userService.getDriverInfo(driverId)
                        : null,
                    builder: (context, snapshot) {
                      String driverName = "Loading...";
                      String? profilePic;

                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData && snapshot.data != null) {
                          driverName = snapshot.data!['name'] ?? 'Unknown User';
                          profilePic = snapshot.data!['photoUrl'];
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
                                            ? driverName[0].toUpperCase()
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
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                        size: 14,
                                      ),
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
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Location, Stops and Distance Section ---
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.green,
                            size: 10,
                          ),
                          Container(
                            height: 20,
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                          const Icon(Icons.circle, color: Colors.red, size: 10),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              startLoc,
                              style: const TextStyle(fontSize: 14),
                            ),
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

                      // ২. ডান দিকে Distance এবং Stops দেখানোর অংশ
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // --- Distance UI ---
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.straighten,
                                  size: 14,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$distance km",
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // --- Stops UI (যদি থাকে) ---
                          if (stopsCount > 0) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$stopsCount stops",
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Tags Section ---
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
                      if (doc['hasAC'] == true)
                        _buildInfoTag(Icons.ac_unit, "AC"),
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
            ),

            // --- Female Only ট্যাগ (Top-Left) ---
            if (isFemaleOnly)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFD9E2),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.female, color: Color(0xFFD61E6D), size: 14),
                      SizedBox(width: 4),
                      Text(
                        "Female Only",
                        style: TextStyle(
                          color: Color(0xFFD61E6D),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            Icons.home,
            "Search",
            _selectedIndex == 0,
            () => setState(() => _selectedIndex = 0),
          ), // হোম
          _buildNavItem(
            Icons.format_list_bulleted,
            "Rides",
            _selectedIndex == 1,
            () => setState(() => _selectedIndex = 1),
          ),
          const SizedBox(width: 40), // FAB এর ফাঁকা জায়গা
          _buildNavItem(
            Icons.inbox_outlined,
            "Requests",
            _selectedIndex == 2,
            () => setState(() => _selectedIndex = 2),
          ),
          _buildNavItem(
            Icons.person_outline,
            "Profile",
            _selectedIndex == 3,
            () => setState(() => _selectedIndex = 3),
          ), // প্রোফাইল
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // নীল রঙের হেডার কার্ড (ইমেজ অনুযায়ী)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2D79FF), Color(0xFF5B42F3)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: _userService.getUserData(
                    auth.FirebaseAuth.instance.currentUser?.uid ?? '',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: CircularProgressIndicator(),
                      );
                    }

                    final userData = snapshot.data ?? {};
                    final userName = userData['name'] ?? 'User';
                    final userRole = userData['userRole'] ?? 'Member';
                    final userGender = userData['gender'] ?? 'Not specified';

                    final firstLetter = userName.isNotEmpty
                        ? userName[0].toUpperCase()
                        : 'U';

                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "$userRole · $userGender",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          auth.FirebaseAuth.instance.currentUser?.email ??
                              'No email',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ভেরিফিকেশন কার্ড (অরেঞ্জ এবং ব্লু)
          _buildVerificationCard(
            "User Not Verified",
            "Verify Now",
            Colors.orange,
          ),
          const SizedBox(height: 12),
          _buildVerificationCard(
            "Driver Not Verified",
            "Verify Now",
            Colors.blue,
          ),

          const SizedBox(height: 20),
          // মেনু আইটেম
          _buildProfileMenuItem(
            Icons.account_balance_wallet_outlined,
            "Wallet & Payments",
          ),
          _buildProfileMenuItem(Icons.security_outlined, "Safety & SOS"),
          _buildProfileMenuItem(Icons.group_outlined, "Carpool Groups"),

          const SizedBox(height: 20),
          // লগআউট বাটন
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await auth.FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Log out", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // প্রোফাইলের জন্য ছোট হেল্পার ফাংশন
  Widget _buildVerificationCard(String title, String btnText, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            child: Text(btnText),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
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
