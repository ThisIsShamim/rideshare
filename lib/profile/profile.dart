import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // আপনার আগের স্ক্রিনগুলোর মতো সেম AppBar
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildVerificationSection(),
                  const SizedBox(height: 20),
                  _buildQuickActions(),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 20),
                  _buildMenuOptions(),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
      // আপনার আগের স্ক্রিনগুলোর মতো সেম FAB এবং BottomNav
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A69FF),
        shape: const CircleBorder(),
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.home, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- Profile Header (Image er moto) ---
  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D79FF), Color(0xFF1A69FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          top: 70,
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.blue.shade100,
                  child: const Text(
                    "A",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Arif Hossain",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildTag("Student"),
                  const SizedBox(width: 8),
                  _buildTag("Male"),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const Text(
                    " 5.0",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.blue, fontSize: 12),
      ),
    );
  }

  // --- Verification Cards ---
  Widget _buildVerificationSection() {
    return Column(
      children: [
        const SizedBox(height: 100), // Space for header overlap
        _buildVerifyCard(
          "User Not Verified",
          "Verify to book & post rides",
          Colors.orange,
          Icons.info_outline,
        ),
        const SizedBox(height: 12),
        _buildVerifyCard(
          "Driver Not Verified",
          "Verify to become a driver",
          Colors.blue,
          Icons.directions_car,
        ),
      ],
    );
  }

  Widget _buildVerifyCard(
    String title,
    String sub,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text("Verify Now", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- Quick Actions (Favorite, Analytics) ---
  Widget _buildQuickActions() {
    return Row(
      children: [
        _buildActionBox("Favorite Routes", Icons.favorite, Colors.purple),
        const SizedBox(width: 12),
        _buildActionBox("Ride Analytics", Icons.bar_chart, Colors.blue),
      ],
    );
  }

  Widget _buildActionBox(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(0.7), color]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Stats Grid ---
  Widget _buildStatsGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("0", "Total Rides", Icons.directions_car),
          _buildStatItem("5.0", "Rating", Icons.star),
          _buildStatItem("৳0", "Balance", Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        Text(
          val,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  // --- Menu Options ---
  Widget _buildMenuOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildListTile(
            Icons.account_balance_wallet_outlined,
            "Wallet & Payments",
          ),
          const Divider(height: 1),
          _buildListTile(Icons.security_outlined, "Safety & SOS"),
          const Divider(height: 1),
          _buildListTile(Icons.group_outlined, "Carpool Groups"),
        ],
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: () {},
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) Navigator.pop(context);
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text("Log out", style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // --- Copy of AppBar and BottomNav ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
          const Text(
            "RideShare",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.grey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(
            Icons.home,
            "Search",
            false,
            () => Navigator.pop(context),
          ),
          _buildNavItem(Icons.format_list_bulleted, "Rides", false, () {}),
          const SizedBox(width: 40),
          _buildNavItem(Icons.inbox_outlined, "Requests", false, () {}),
          _buildNavItem(Icons.person, "Profile", true, () {}),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF1A69FF) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF1A69FF) : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
