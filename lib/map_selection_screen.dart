import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  GoogleMapController? _mapController;

  // ডিফল্ট লোকেশন (যেমন: ঢাকা)
  LatLng _currentPosition = const LatLng(23.8103, 90.4125);
  String _selectedAddress = "Drag the map to select a location";

  // ম্যাপ সরানোর পর লোকেশনের নাম বের করা (Reverse Geocoding)
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _selectedAddress =
              "${place.street}, ${place.subLocality}, ${place.locality}";
        });
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ১. গুগল ম্যাপ
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _currentPosition = position.target;
            },
            onCameraIdle: () {
              // ম্যাপ থামার পর ওই জায়গার ঠিকানা বের করবে
              _getAddressFromLatLng(_currentPosition);
            },
          ),

          // ২. ম্যাপের মাঝখানে একটি পিন আইকন (Center Marker)
          const Icon(Icons.location_on, size: 40, color: Colors.red),

          // ৩. উপরে সার্চ বক্স
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search a place...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
                // নোট: এখানে Google Places API ইন্টিগ্রেট করতে হবে আসল সার্চের জন্য
              ),
            ),
          ),

          // ৪. নিচে অ্যাড্রেস প্রিভিউ এবং কনফার্ম বাটন
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedAddress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // কনফার্ম করলে আগের পেজে লোকেশনের নাম নিয়ে ফিরে যাবে
                          Navigator.pop(context, _selectedAddress);
                        },
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
