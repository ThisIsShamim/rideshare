import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  // ডিফল্ট লোকেশন (ঢাকা)
  LatLng _currentPosition = const LatLng(23.8103, 90.4125);
  String _selectedAddress = "Fetching location...";
  final MapController _mapController = MapController();

  // ম্যাপ রেডি হয়েছে কিনা তা চেক করার জন্য
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    // অ্যাপ ওপেন হওয়ার সাথে সাথেই লোকেশন খুঁজবে
    _getUserCurrentLocation();
  }

  // ইউজারের লাইভ লোকেশন বের করা
  Future<void> _getUserCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _selectedAddress = "Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _selectedAddress = "Location permission denied.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(
        () => _selectedAddress = "Location permissions are permanently denied.",
      );
      return;
    }

    try {
      // লাইভ লোকেশন নেওয়া
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // লোকেশন ভ্যালিড কিনা চেক করা (যাতে NaN এরর না আসে)
      if (!position.latitude.isNaN && !position.longitude.isNaN) {
        LatLng liveLocation = LatLng(position.latitude, position.longitude);

        setState(() {
          _currentPosition = liveLocation;
        });

        // ম্যাপ পুরোপুরি রেডি হলেই কেবল ক্যামেরা মুভ করবে
        if (_isMapReady) {
          _mapController.move(liveLocation, 15.0);
        }

        _getAddressFromLatLng(liveLocation);
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
      setState(() => _selectedAddress = "Could not get current location");
    }
  }

  // ম্যাপ সরানোর পর লোকেশনের নাম বের করা
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      setState(() {
        _selectedAddress = "Loading address...";
      });

      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        setState(() {
          _selectedAddress =
              "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}";
        });
      }
    } catch (e) {
      debugPrint("Error fetching address: $e");
      setState(() {
        _selectedAddress = "Address not found";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // আপনার অ্যাপের থিমের সাথে ম্যাচ করা প্রাইমারি ব্লু কালার
    final Color appPrimaryColor = const Color(0xFF1658C9);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: appPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // ১. ফ্রি ম্যাপ
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 15.0,

              // 👇 এই onTap ফাংশনটি নতুন করে অ্যাড করতে হবে
              onTap: (TapPosition tapPosition, LatLng point) {
                setState(() {
                  _currentPosition = point;
                });
                // ম্যাপের সেন্টার ক্লিক করা জায়গায় মুভ করে দিচ্ছি
                _mapController.move(point, _mapController.camera.zoom);
                // নতুন জায়গার অ্যাড্রেস ফেচ করছি
                _getAddressFromLatLng(point);
              },

              // 👆 শেষ
              onMapReady: () {
                _isMapReady = true;
                _mapController.move(_currentPosition, 15.0);
              },
              onPositionChanged: (MapCamera camera, bool hasGesture) {
                if (hasGesture && !camera.center.latitude.isNaN) {
                  setState(() {
                    _currentPosition = camera.center;
                  });
                }
              },
              onMapEvent: (MapEvent event) {
                if (event is MapEventMoveEnd) {
                  _getAddressFromLatLng(_currentPosition);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourname.yourapp',
              ),
            ],
          ),

          // ২. ম্যাপের মাঝখানে পিন আইকন (থিমের সাথে মিলিয়ে গাঢ় নীল বা লাল রাখতে পারেন)
          const Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Icon(
              Icons.location_on,
              size: 50,
              color: Colors.redAccent,
            ), // পিনটা লাল রাখলাম যাতে ম্যাপে সহজে চোখে পড়ে
          ),

          // ৩. উপরে সার্চ বক্স (একটু রাউন্ডেড এবং শ্যাডো দিয়েছি আপনার অ্যাপের মতো)
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                  12,
                ), // আপনার অ্যাপের ইনপুট ফিল্ডের মতো শেপ
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search a place...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),

          // ৪. নিচে অ্যাড্রেস প্রিভিউ এবং কনফার্ম বাটন
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place, color: appPrimaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedAddress,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height:
                          50, // বাটনের হাইট একটু বাড়িয়েছি আপনার ডিজাইনের মতো
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appPrimaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // আপনার অ্যাপের বাটনের রাউন্ডনেস
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context, {
                            'address': _selectedAddress,
                            'latLng': _currentPosition,
                          });
                        },
                        child: const Text(
                          'Continue', // আপনার অ্যাপের বাটনের লেখার স্টাইলে দিলাম
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ৫. মাই লোকেশন বাটন
          Positioned(
            bottom: 170,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: _getUserCurrentLocation,
              child: Icon(
                Icons.my_location,
                color: appPrimaryColor,
              ), // আইকনের কালার থিমের ব্লু করে দিলাম
            ),
          ),
        ],
      ),
    );
  }
}
