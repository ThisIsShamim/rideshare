import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFigmaHeader(), // The Updated Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // --- VERIFICATION CARDS ---
                  _buildVerifyCard(
                    "User Not Verified",
                    "Verify to book & post rides",
                    const Color(0xFFF2994A),
                    const Color(0xFFFFF7EE),
                    Icons.error,
                  ),
                  const SizedBox(height: 12),
                  _buildVerifyCard(
                    "Driver Not Verified",
                    "Verify to become a driver",
                    const Color(0xFF2F80ED),
                    const Color(0xFFF4F8FF),
                    Icons.directions_car,
                  ),

                  const SizedBox(height: 24),
                  const Text("Quick Actions",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333))),
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
                        _statCol("0", "Total Rides", Icons.directions_car, const Color(0xFF2F80ED)),
                        _statCol("5.0", "Rating", Icons.star_rounded, const Color(0xFFF2C94C)),
                        _statCol("10", "Balance", Icons.account_balance_wallet, const Color(0xFF9B51E0)),
                        _statCol("3", "Points", Icons.emoji_events, const Color(0xFF27AE60)),
                        _statCol("0kg", "CO2 Saved", Icons.eco_rounded, const Color(0xFF219653)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildTabs(),

                  const SizedBox(height: 20),

                  // --- ACHIEVEMENTS ---
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF1F4F8)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("ACHIEVEMENTS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF828282), letterSpacing: 0.5)),
                            Text("1/6 unlocked", style: TextStyle(fontSize: 11, color: Color(0xFF2F80ED), fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _achievementBadge(Icons.directions_car_filled, "First 5", "5+ rides", const Color(0xFFEB5757), true),
                            _achievementBadge(Icons.bolt_rounded, "On a Roll", "10+ rides", const Color(0xFFF2C94C), false),
                            _achievementBadge(Icons.emoji_events_rounded, "Champion", "50+ rides", const Color(0xFFF2994A), false),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _achievementBadge(Icons.star_rounded, "Top Rated", "4.5+ rating", const Color(0xFFF2C94C), false),
                            _achievementBadge(Icons.eco_rounded, "Eco Hero", "100kg CO2", const Color(0xFF219653), false),
                            _achievementBadge(Icons.verified_user_rounded, "Verified", "ID verified", const Color(0xFF27AE60), false),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildMenuSection(),

                  const SizedBox(height: 30),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Logout", style: TextStyle(color: Color(0xFFEB5757), fontWeight: FontWeight.bold, fontSize: 16)),
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

  // --- UPDATED FIGMA HEADER (WITH OVERLAP & BADGES) ---
  Widget _buildFigmaHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2F80ED), Color(0xFF56CCF2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
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
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overlapping Avatar
                      Transform.translate(
                        offset: const Offset(0, -35),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Center(
                            child: Text(
                              "A",
                              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Edit Button
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF2F2F2)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.edit_outlined, size: 12, color: Color(0xFF828282)),
                            SizedBox(width: 4),
                            Text("Edit Profile", style: TextStyle(fontSize: 10, color: Color(0xFF4F4F4F), fontWeight: FontWeight.w600)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Arif Hossain",
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF333333)),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.star, color: Color(0xFFF2C94C), size: 16),
                                Text(" 5.0", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Student Pill Label
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F80ED).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text("Student", style: TextStyle(color: Color(0xFF2F80ED), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            const Text("Male", style: TextStyle(color: Color(0xFF828282), fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Icon(Icons.phone_outlined, size: 14, color: Color(0xFFBDBDBD)),
                            SizedBox(width: 4),
                            Text("01312345678", style: TextStyle(color: Color(0xFF828282), fontSize: 10)),
                            SizedBox(width: 12),
                            Icon(Icons.email_outlined, size: 14, color: Color(0xFFBDBDBD)),
                            SizedBox(width: 4),
                            Text("arif.hossain@gmail.com", style: TextStyle(color: Color(0xFF828282), fontSize: 10)),
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

  // --- OTHER UI HELPERS ---
  Widget _buildVerifyCard(String title, String subtitle, Color mainColor, Color bgColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mainColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: mainColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF333333))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: mainColor,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size(80, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Verify Now", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _achievementBadge(IconData icon, String title, String sub, Color color, bool isUnlocked) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            height: 55, width: 55,
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: isUnlocked ? Colors.black87 : const Color(0xFF828282), fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(sub, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: Color(0xFFBDBDBD))),
        ],
      ),
    );
  }

  Widget _statCol(String val, String label, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333))),
        const SizedBox(height: 2),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF828282), fontSize: 9)),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon, List<Color> colors, String sub) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(right: -10, bottom: -10, child: Icon(icon, color: Colors.white.withOpacity(0.15), size: 70)),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.2)),
                  Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Column(children: [
          const Text("Overview", style: TextStyle(color: Color(0xFF2F80ED), fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Container(height: 3, width: 65, color: const Color(0xFF2F80ED))
        ]),
        const SizedBox(width: 30),
        const Text("History", style: TextStyle(color: Color(0xFF828282), fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _menuTile(Icons.account_balance_wallet_outlined, "Wallet & Payments", "Tk 0 balance", const Color(0xFF27AE60)),
        _menuTile(Icons.shield_outlined, "Safety & SOS", "Emergency contacts", const Color(0xFFEB5757)),
        _menuTile(Icons.group_outlined, "Carpool Groups", "Your groups", const Color(0xFF2F80ED)),
      ],
    );
  }

  Widget _menuTile(IconData icon, String title, String sub, Color col) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: col, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF828282))),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Color(0xFFBDBDBD)),
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
    );
  }
}