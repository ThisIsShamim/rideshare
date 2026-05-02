import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // এখানে ভেরিয়েবলগুলো রাখা হয়েছে যাতে এডিট করলে ডেটা পরিবর্তন করা যায়
  String userName = 'Arif Hossain';
  String userPhone = '01812345678';
  String userEmail = 'arif.hossain@gmail.com';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 40),
            _buildUserInfo(), // এই ফাংশনে এখন ভেরিয়েবল থেকে ডেটা যাবে
            const SizedBox(height: 20),
            _buildStatsRow(),
            const SizedBox(height: 20),
            _buildTabs(),
            const SizedBox(height: 20),
            _buildAchievements(),
            const SizedBox(height: 20),
            _buildMenuItems(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue[600],
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(), 
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              children: [
                TextSpan(text: 'Ride', style: TextStyle(color: Colors.blue[900])),
                const TextSpan(text: 'Share', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.black54),
          onPressed: () {},
        ),
        const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue,
            child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.blue[400]!, Colors.blue[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: 32,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U', // নামের প্রথম অক্ষর দেখাবে
                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          right: 32,
          child: OutlinedButton.icon(
            onPressed: () {
              _showEditProfileBottomSheet(); 
            },
            icon: const Icon(Icons.edit, size: 14, color: Colors.black87),
            label: const Text('Edit Profile', style: TextStyle(color: Colors.black87, fontSize: 12)),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              minimumSize: const Size(0, 30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                userName, // ভেরিয়েবল থেকে নাম আসছে
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  const Text('5.0', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('Student', style: TextStyle(color: Colors.blue[700], fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text('Male', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(userPhone, style: TextStyle(color: Colors.grey[600], fontSize: 12)), // ফোন নম্বর ভেরিয়েবল
              const SizedBox(width: 16),
              Icon(Icons.email, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(userEmail, style: TextStyle(color: Colors.grey[600], fontSize: 12)), // ইমেইল ভেরিয়েবল
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _statItem(Icons.directions_car, Colors.blue, '0', 'Total Rides'),
            _statItem(Icons.star_border, Colors.amber, '5.0', 'Rating'),
            _statItem(Icons.account_balance_wallet_outlined, Colors.green, '৳0', 'Balance'),
            _statItem(Icons.military_tech_outlined, Colors.purple, '0', 'Points'),
            _statItem(Icons.eco_outlined, Colors.teal, '0kg', 'CO2 Saved'),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, Color iconColor, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 10)),
      ],
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.grid_view, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text('History', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ACHIEVEMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black54)),
              Text('1/6 unlocked', style: TextStyle(color: Colors.blue[600], fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2))),
              Container(width: 50, height: 4, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _achievementBadge(Icons.local_taxi, Colors.red[300]!, 'First 5', '5+ rides', false),
              _achievementBadge(Icons.local_fire_department, Colors.orange[300]!, 'On a Roll', '10+ rides', false),
              _achievementBadge(Icons.emoji_events, Colors.amber, 'Champion', '50+ rides', false),
              _achievementBadge(Icons.star, Colors.green, 'Top Rated', '4.5+ rating', true),
              _achievementBadge(Icons.eco, Colors.teal[300]!, 'Eco Hero', '100kg CO2', false),
              _achievementBadge(Icons.verified_user, Colors.blue[300]!, 'Verified', 'ID verified', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _achievementBadge(IconData icon, Color color, String title, String subtitle, bool isUnlocked) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUnlocked ? color.withOpacity(0.1) : Colors.grey[50],
              shape: BoxShape.circle,
              border: Border.all(color: isUnlocked ? color : Colors.grey[200]!),
            ),
            child: Icon(icon, color: isUnlocked ? color : Colors.grey[300], size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black87 : Colors.grey[400]), textAlign: TextAlign.center),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey[400]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _menuItem(Icons.account_balance_wallet_outlined, 'Wallet & Payments', 'Cards, balance & history', Colors.blue),
        _menuItem(Icons.health_and_safety_outlined, 'Safety & SOS', 'Emergency contacts', Colors.red),
        _menuItem(Icons.group_outlined, 'Carpool Groups', 'Your groups', Colors.purple),
        const SizedBox(height: 20),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, String subtitle, Color iconColor) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: () {},
    );
  }

  // --- Bottom Navigation Bar Section ---
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 65, 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildNavItem(Icons.home_outlined, 'Search', false, () {}),
            _buildNavItem(Icons.list_alt, 'Rides', false, () {}),
            const SizedBox(width: 48), // Space for the FAB
            _buildNavItem(Icons.person, 'Profile', true, () {}),
            _buildNavItem(Icons.more_horiz, 'More', false, () {
              _showMoreBottomSheet(); 
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
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
              color: isSelected ? Colors.blue[600] : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue[600] : Colors.grey[400],
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- More Features Bottom Sheet ---
  void _showMoreBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('More Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
                        child: const Icon(Icons.close, color: Colors.black54, size: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildBottomSheetMenuItem(
                icon: Icons.group_outlined, title: 'Carpool Groups', subtitle: 'Join or manage groups', onTap: () {},
              ),
              _buildBottomSheetMenuItem(
                icon: Icons.account_balance_wallet_outlined, title: 'Wallet', subtitle: 'Balance & transactions', onTap: () {},
              ),
              _buildBottomSheetMenuItem(
                icon: Icons.health_and_safety_outlined, title: 'Safety & SOS', subtitle: 'Emergency contacts', onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetMenuItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: onTap,
    );
  }

  // --- Edit Profile Bottom Sheet ---
  void _showEditProfileBottomSheet() {
    // বর্তমান ডেটা দিয়ে কন্ট্রোলারগুলো ইনিশিয়ালাইজ করা হচ্ছে
    final TextEditingController nameController = TextEditingController(text: userName);
    final TextEditingController phoneController = TextEditingController(text: userPhone);
    final TextEditingController emailController = TextEditingController(text: userEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField(label: 'Full Name', controller: nameController),
              const SizedBox(height: 16),
              _buildTextField(label: 'Phone Number', controller: phoneController, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(label: 'Email', controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // সেভ বাটনে ক্লিক করলে ডেটা আপডেট হবে
                        setState(() {
                          userName = nameController.text;
                          userPhone = phoneController.text;
                          userEmail = emailController.text;
                        });
                        Navigator.pop(context); // বটম শিট বন্ধ করবে
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
        ),
      ],
    );
  }
}