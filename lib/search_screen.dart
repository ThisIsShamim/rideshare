import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindRideScreen extends StatefulWidget {
  const FindRideScreen({super.key});

  @override
  State<FindRideScreen> createState() => _FindRideScreenState();
}

class _FindRideScreenState extends State<FindRideScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFiltersSection(),
          Expanded(
            // StreamBuilder দিয়ে ফায়ারবেস থেকে রিয়েল-টাইম ডেটা আনা হচ্ছে
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .where('status', isEqualTo: 'active')
                  .snapshots(), // শুধু active রাইডগুলো আনবে
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong!'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rides = snapshot.data!.docs;

                if (rides.isEmpty) {
                  return const Center(
                    child: Text('No rides available right now.'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    var rideData = rides[index].data() as Map<String, dynamic>;
                    return _buildRideCard(rideData);
                  },
                );
              },
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
      title: const Text(
        'Find a Ride',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 16, color: Colors.black),
            label: const Text('Filters', style: TextStyle(color: Colors.black)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Female Only rides are hidden from your results for safety.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('Soonest', Icons.access_time, isSelected: true),
                _buildChip('Cheapest', Icons.monetization_on_outlined),
                _buildChip('Top Rated', Icons.star_border),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('Car', Icons.directions_car_outlined),
                _buildChip('Bike', Icons.two_wheeler),
                _buildChip('AC', Icons.ac_unit),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black87),
        ),
        avatar: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.blue,
          size: 18,
        ),
        selected: isSelected,
        onSelected: (bool value) {},
        backgroundColor: Colors.white,
        selectedColor: Colors.blue[600],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> data) {
    // ১. Time Format করা
    String formattedTime = 'Time N/A';
    if (data['departureTime'] != null) {
      DateTime dateTime = (data['departureTime'] as Timestamp).toDate();
      final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      final monthNames = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      formattedTime =
          '${dateTime.day} ${monthNames[dateTime.month - 1]} - $hour:$minute $period';
    }

    // ২. Stops এবং Vehicle Info
    int stopsCount = (data['stops'] is List)
        ? (data['stops'] as List).length
        : 0;
    String vehicleName =
        '${data['vehicleColor'] ?? ''} ${data['vehicleModel'] ?? ''}'.trim();
    if (vehicleName.isEmpty) vehicleName = data['vehicleType'] ?? 'Vehicle';

    // ৩. Driver ID সংগ্রহ (আপনার rides কালেকশনের 'driverId')
    String driverId = data['driverId'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header Section with FutureBuilder (Updated with Query) ---
          FutureBuilder<QuerySnapshot>(
            // এখানে doc() এর বদলে where() ব্যবহার করা হয়েছে
            future: driverId.isNotEmpty
                ? FirebaseFirestore.instance
                      .collection('users')
                      .where(
                        'uid',
                        isEqualTo: driverId,
                      ) // users এর uid ফিল্ডের সাথে মেলাবে
                      .limit(1)
                      .get()
                : null,
            builder: (context, snapshot) {
              String driverName = "Loading...";
              String? profilePic;

              if (snapshot.connectionState == ConnectionState.done) {
                // চেক করা হচ্ছে ডকুমেন্ট পাওয়া গেছে কি না
                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  // প্রথম ডকুমেন্টটি নেওয়া হলো
                  var userData =
                      snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  // আপনার ইউজার ডেটাবেস অনুযায়ী 'fullname' ফেচ করা হচ্ছে
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
                        radius: 22,
                        backgroundColor: Colors.blue[100],
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
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                driverName, // এখানে ফায়ারবেস থেকে আসা নাম দেখাবে
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ), // নামের এবং আইকনের মাঝে একটু ফাঁকা
                              const Icon(
                                Icons
                                    .verified, // নামের ঠিক পাশেই ভেরিফাইড ব্লু-টিক
                                color: Colors.blue,
                                size: 16,
                              ),
                            ],
                          ),
                          // "Verified Driver" টেক্সটটি এখান থেকে পুরোপুরি মুছে দেওয়া হয়েছে
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳${data['pricePerSeat'] ?? '0'}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        'per seat',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // --- Route Locations ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRouteRow(
                      Icons.circle,
                      Colors.green,
                      data['fromLocation'] ?? 'Origin',
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 5),
                      height: 15,
                      width: 2,
                      color: Colors.grey[300],
                    ),
                    _buildRouteRow(
                      Icons.circle,
                      Colors.red,
                      data['toLocation'] ?? 'Destination',
                    ),
                  ],
                ),
              ),
              if (stopsCount > 0) _buildStopBadge(stopsCount),
            ],
          ),
          const SizedBox(height: 16),

          // --- Details Badges ---
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(Icons.access_time, formattedTime),
              _buildBadge(
                Icons.group,
                '${data['availableSeats'] ?? 0} seat left',
                textColor: Colors.blue,
                bgColor: Colors.blue[50],
              ),
              _buildBadge(Icons.directions_car, vehicleName),
              if (data['hasAC'] == true)
                _buildBadge(
                  Icons.ac_unit,
                  'AC',
                  textColor: Colors.teal,
                  bgColor: Colors.teal[50],
                ),
              if (data['isFemaleOnly'] == true)
                _buildBadge(
                  Icons.female,
                  'Female Only',
                  textColor: Colors.pink,
                  bgColor: Colors.pink[50],
                ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Action Buttons ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Details',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      color: Colors.white,
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

  // Helper Widget: রুট রো তৈরির জন্য (কোড ক্লিন রাখার জন্য)
  Widget _buildRouteRow(IconData icon, Color color, String location) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            location,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper Widget: স্টপ ব্যাজ
  Widget _buildStopBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.blue, size: 12),
          const SizedBox(width: 4),
          Text(
            '$count stops',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    IconData icon,
    String text, {
    Color? textColor,
    Color? bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: textColor ?? Colors.grey[700],
              fontWeight: textColor != null
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
