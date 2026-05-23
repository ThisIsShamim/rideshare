import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rideshare/profile/wallet_screen.dart';
import 'package:rideshare/profile/verification_dialogs.dart'; // আপনার সঠিক পাথ অনুযায়ী ইমপোর্ট করুন
import '../login_screen.dart'; // আপনার ফাইলের সঠিক পাথ দিন

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Firebase Data Variables
  String _fullName = "Loading...";
  String _email = "Loading...";
  String _gender = "Loading...";
  String _userType = "User";
  String _totalRides = "0"; // Dynamically fetched from bookings
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchUserStats();
  }

  // --- FETCH USER PROFILE DATA ---
  Future<void> _fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _fullName = data['fullname'] ?? "Unknown User";
            _email = data['email'] ?? "No email provided";
            _gender = data['gender'] ?? "N/A";
            _userType = data['usertype'] ?? "User";
            _isLoading = false;
          });
        } else {
          setState(() {
            _fullName = "User Not Found";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _fullName = "Not Logged In";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _fullName = "Error loading data";
        _isLoading = false;
      });
    }
  }

  // --- FETCH USER TOTAL RIDES ---
  Future<void> _fetchUserStats() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // এখানে bookings এর বদলে rides কালেকশন এবং uid এর বদলে driverId দেওয়া হয়েছে
        QuerySnapshot rideSnapshot = await FirebaseFirestore.instance
            .collection('rides') // আপনার ডাটাবেজ অনুযায়ী কালেকশন নাম (rides)
            .where(
              'driverId',
              isEqualTo: currentUser.uid,
            ) // আপনার ফিল্ডের নাম (driverId)
            .get();

        if (mounted) {
          setState(() {
            _totalRides = rideSnapshot.docs.length.toString();
          });
        }
      }
    } catch (e) {
      print("Error fetching total rides: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFigmaHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // --- VERIFICATION CARDS ---
                  // --- VERIFICATION CARDS IN PROFILE.DART ---
                  _buildVerifyCard(
                    context,
                    "User Not Verified",
                    "Verify to book & post rides",
                    const Color(0xFFF2994A),
                    const Color(0xFFFFF7EE),
                    Icons.error,
                    onTap: () => VerificationDialogs.showUserVerification(
                      context,
                    ), // এখানে কল করুন
                  ),
                  const SizedBox(height: 12),
                  _buildVerifyCard(
                    context,
                    "Driver Not Verified",
                    "Verify to become a driver",
                    const Color(0xFF2F80ED),
                    const Color(0xFFF4F8FF),
                    Icons.directions_car,
                    onTap: () => VerificationDialogs.showDriverVerification(
                      context,
                    ), // এখানে কল করুন
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- QUICK ACTIONS ---
                  Row(
                    children: [
                      _buildQuickAction(
                        "Favorite\nRoutes",
                        Icons.favorite_rounded,
                        [const Color(0xFF9B51E0), const Color(0xFF8E2DE2)],
                        "Quick access",
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        "Ride\nAnalytics",
                        Icons.bar_chart_rounded,
                        [const Color(0xFF2D9CDB), const Color(0xFF2F80ED)],
                        "View insights",
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- STATS ROW ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F4F8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCol(
                          _totalRides, // Dynamically loaded total rides
                          "Total Rides",
                          Icons.directions_car,
                          const Color(0xFF2F80ED),
                        ),
                        _statCol(
                          "5.0",
                          "Rating",
                          Icons.star_rounded,
                          const Color(0xFFF2C94C),
                        ),
                        _statCol(
                          "10",
                          "Balance",
                          Icons.account_balance_wallet,
                          const Color(0xFF9B51E0),
                        ),
                        _statCol(
                          "3",
                          "Points",
                          Icons.emoji_events,
                          const Color(0xFF27AE60),
                        ),
                        _statCol(
                          "0kg",
                          "CO2 Saved",
                          Icons.eco_rounded,
                          const Color(0xFF219653),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildTabs(),

                  const SizedBox(height: 20),

                  // --- ACHIEVEMENT SECTION ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F4F8)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "ACHIEVEMENTS",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF828282),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              "1/6 unlocked",
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2F80ED),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _achievementBadge(
                              Icons.directions_car_filled,
                              "First 5",
                              "5+ rides",
                              const Color(0xFFEB5757),
                              true,
                            ),
                            _achievementBadge(
                              Icons.bolt_rounded,
                              "On a Roll",
                              "10+ rides",
                              const Color(0xFFF2C94C),
                              false,
                            ),
                            _achievementBadge(
                              Icons.emoji_events_rounded,
                              "Champion",
                              "50+ rides",
                              const Color(0xFFF2994A),
                              false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _achievementBadge(
                              Icons.star_rounded,
                              "Top Rated",
                              "4.5+ rating",
                              const Color(0xFFF2C94C),
                              false,
                            ),
                            _achievementBadge(
                              Icons.eco_rounded,
                              "Eco Hero",
                              "100kg CO2",
                              const Color(0xFF219653),
                              false,
                            ),
                            _achievementBadge(
                              Icons.verified_user_rounded,
                              "Verified",
                              "ID verified",
                              const Color(0xFF27AE60),
                              false,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildMenuSection(context),

                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        try {
                          // ১. ফায়ারবেস থেকে ইউজারকে সাইন-আউট করা
                          await FirebaseAuth.instance.signOut();

                          // ২. লগিন পেজে পাঠানো এবং পেছনের সব স্ক্রিন রিমুভ করে দেওয়া
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LoginScreen(), // আপনার লগিন পেজের ক্লাসের নাম দিন
                              ),
                              (route) =>
                                  false, // এটি ব্যাকগ্রাউন্ডের সব পেজ মুছে ফেলবে
                            );
                          }
                        } catch (e) {
                          print("Logout Error: $e");
                        }
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Color(0xFFEB5757),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MENU SECTION WITH NAVIGATION ---
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      children: [
        _menuTile(
          Icons.account_balance_wallet_outlined,
          "Wallet & Payments",
          "Tk 0 balance",
          const Color(0xFF27AE60),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            );
          },
        ),
        _menuTile(
          Icons.shield_outlined,
          "Safety & SOS",
          "Emergency contacts",
          const Color(0xFFEB5757),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SafetyCenterScreen(),
              ),
            );
          },
        ),
        _menuTile(
          Icons.group_outlined,
          "Carpool Groups",
          "Your groups",
          const Color(0xFF2F80ED),
        ),
      ],
    );
  }

  Widget _menuTile(
    IconData icon,
    String title,
    String sub,
    Color col, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: col.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: col, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(fontSize: 11, color: Color(0xFF828282)),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: Color(0xFFBDBDBD),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: Color(0xFF2F80ED),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Color(0xFF4F4F4F)),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaHeader(BuildContext context) {
    // Generate avatar initial dynamically
    String initial =
        _fullName.isNotEmpty &&
            _fullName != "Loading..." &&
            _fullName != "Error loading data"
        ? _fullName[0].toUpperCase()
        : "U";

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2F80ED),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -35),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2F80ED),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFF2F2F2),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 12,
                                    color: Color(0xFF828282),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Edit Profile",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF4F4F4F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Transform.translate(
                          offset: const Offset(0, -15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _fullName, // Dynamically loaded name
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.star,
                                        color: Color(0xFFF2C94C),
                                        size: 16,
                                      ),
                                      Text(
                                        " 5.0",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2F80ED,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _userType, // Dynamically loaded usertype
                                      style: const TextStyle(
                                        color: Color(0xFF2F80ED),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _gender, // Dynamically loaded gender
                                    style: const TextStyle(
                                      color: Color(0xFF828282),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    size: 14,
                                    color: Color(0xFFBDBDBD),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "01312345678",
                                    style: TextStyle(
                                      color: Color(0xFF828282),
                                      fontSize: 10,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.email_outlined,
                                    size: 14,
                                    color: Color(0xFFBDBDBD),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _email, // Dynamically loaded email
                                    style: const TextStyle(
                                      color: Color(0xFF828282),
                                      fontSize: 10,
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
        ),
      ],
    );
  }

  Widget _buildSearchableInput({
    required TextEditingController controller,
    required String hint,
    required List<String> items,
    required VoidCallback onChanged,
  }) {
    List<String> filteredItems = items
        .where((i) => i.toLowerCase().contains(controller.text.toLowerCase()))
        .toList();
    return Column(
      children: [
        TextField(
          controller: controller,
          onChanged: (val) => onChanged(),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF9FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (controller.text.isNotEmpty && filteredItems.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF2F2F2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: filteredItems.length,
              itemBuilder: (context, i) => ListTile(
                dense: true,
                title: Text(
                  filteredItems[i],
                  style: const TextStyle(fontSize: 13),
                ),
                onTap: () {
                  controller.text = filteredItems[i];
                  onChanged();
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerifyCard(
    BuildContext context,
    String title,
    String sub,
    Color main,
    Color bg,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: main.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: main, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF333333),
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: main,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(80, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              "Verify Now",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- UPDATED FIELD LABEL (লাল স্টার * সাপোর্ট করার জন্য) ---
  Widget _buildFieldLabel(String label) {
    bool hasAsterisk = label.contains('*');
    String text = label.replaceAll('*', '').trim();

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              fontFamily: 'Roboto', // আপনার অ্যাপের ফন্ট দিন
            ),
            children: hasAsterisk
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }

  // --- NEW: ব্লু চেকলিস্ট আইটেম তৈরি করার জন্য ---
  Widget _buildCheckItemBlue(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: Color(0xFF2F80ED)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: Color(0xFF2F80ED)),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF2F2F2)),
      ),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFBDBDBD),
          ),
        ],
      ),
    );
  }

  Widget _statCol(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF333333),
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF828282), fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    List<Color> colors,
    String sub,
  ) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                icon,
                color: Colors.white.withOpacity(0.15),
                size: 70,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Text(
                    sub,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _achievementBadge(
    IconData icon,
    String title,
    String sub,
    Color color,
    bool isUnlocked,
  ) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isUnlocked ? Colors.black87 : const Color(0xFF828282),
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, color: Color(0xFFBDBDBD)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Column(
          children: [
            const Text(
              "Overview",
              style: TextStyle(
                color: Color(0xFF2F80ED),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 3, width: 65, color: const Color(0xFF2F80ED)),
          ],
        ),
        const SizedBox(width: 30),
        const Text(
          "History",
          style: TextStyle(
            color: Color(0xFF828282),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        const Icon(Icons.circle, size: 6, color: Color(0xFF2F80ED)),
        const SizedBox(width: 10),
        Text(t, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}

// -------------------------------------------------------------------------
// SAFETY CENTER SCREEN CLASS

class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Safety Center",
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Your security and peace of mind, our priority",
              style: TextStyle(color: Color(0xFF828282), fontSize: 11),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.shield_outlined, color: Colors.blue.shade600),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- EMERGENCY SOS SECTION ---
            _buildEmergencySOS(),

            const SizedBox(height: 24),
            Row(
              children: const [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF2F80ED),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  "Active Safety Features",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- FIGMA MATCHING VERTICAL CARDS (SAME TO SAME LIKE IMAGE) ---
            _buildFigmaSafetyCard(
              icon: Icons.location_on,
              title: "Live Location Sharing",
              desc:
                  "Real-time GPS tracking shared with\ntrusted contacts during your rides.",
              color: const Color(0xFF2F80ED),
              statusText: "Active",
            ),
            _buildFigmaSafetyCard(
              icon: Icons.verified_user,
              title: "ID Verification",
              desc: "University ID verified for enhanced\nsecurity and trust.",
              color: const Color(0xFF27AE60),
              statusText: "Verified",
            ),
            _buildFigmaSafetyCard(
              icon: Icons.access_time_filled,
              title: "Arrival Check-in",
              desc:
                  "Auto-notify contacts when you safely\nreach your destination.",
              color: const Color(0xFF9B51E0),
              statusText: "Enabled",
            ),

            const SizedBox(height: 24),

            // --- EMERGENCY CONTACTS SECTION ---
            _buildEmergencyContactsSection(),

            const SizedBox(height: 24),

            // --- SAFETY TIPS SECTION ---
            _buildSafetyTipsSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- EXACT UI FOR SAFETY CARDS (From image_8507a2.jpg) ---
  Widget _buildFigmaSafetyCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required String statusText,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F4F8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF828282),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          // Full-width pill shaped button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SOS SECTION ---
  Widget _buildEmergencySOS() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEB5757),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Emergency SOS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "One-tap emergency response",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Instantly alert your emergency contacts with your real-time location and send an SOS notification.",
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFEB5757),
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Activate Emergency SOS",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- SAFETY TIPS SECTION ---
  Widget _buildSafetyTipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F8FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Color(0xFFF2994A), size: 20),
              SizedBox(width: 8),
              Text(
                "Safety Tips & Precautions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _tipRow("Always verify the driver and vehicle details."),
          _tipRow("Share your live journey with someone you trust."),
          _tipRow("Check-in via the app when you reach safely."),
          _tipRow("Trust your instincts—cancel if you feel unsafe."),
          _tipRow("Keep your emergency contacts updated regularly."),
        ],
      ),
    );
  }

  Widget _tipRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF27AE60), size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: Color(0xFF4F4F4F)),
            ),
          ),
        ],
      ),
    );
  }

  // --- EMERGENCY CONTACTS SECTION ---
  Widget _buildEmergencyContactsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F4F8), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.people_outline,
                    color: Color(0xFF2F80ED),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Emergency Contacts",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2F80ED),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 30),
                ),
                child: const Text(
                  "+ Add Contact",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(Icons.phone_outlined, size: 40, color: Color(0xFFBDBDBD)),
          const SizedBox(height: 8),
          const Text(
            "No contacts added yet",
            style: TextStyle(fontSize: 12, color: Color(0xFF828282)),
          ),
        ],
      ),
    );
  }
}
