import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ইউজার বা ড্রাইভারের ডেটা ফেচ করার কমন ফাংশন
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }

  // ড্রাইভারের নাম এবং ছবি ফেচ করার জন্য
  Future<Map<String, String?>> getDriverInfo(String driverId) async {
    final data = await getUserData(driverId);
    if (data != null) {
      return {
        // আপনার ডাটাবেসে 'fullname' আছে, তাই এটি প্রথমে চেক করবে
        'name': data['fullname']?.toString() ?? 'Unknown User',

        // আপনার বর্তমান ডাটাবেসে ছবির ফিল্ড নেই। ভবিষ্যতে যোগ করলে সেটা এখান থেকে নিবে।
        'photoUrl':
            data['photoUrl']?.toString() ?? data['profilePicture']?.toString(),
      };
    }
    return {'name': 'Unknown', 'photoUrl': null};
  }
}
