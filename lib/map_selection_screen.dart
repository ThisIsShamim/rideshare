import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// --- University Model ---
class University {
  final String name;
  final LatLng location;
  final String logoUrl;

  University({
    required this.name,
    required this.location,
    required this.logoUrl,
  });
}

class MapSelectionScreen extends StatefulWidget {
  const MapSelectionScreen({super.key});

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  // Uber Theme Colors
  final Color appPrimaryColor = Colors.black;
  final Color surfaceColor = Colors.white;
  final Color textColor = Colors.black87;
  final Color subtitleColor = Colors.grey.shade600;

  final MapController _mapController = MapController();

  final TextEditingController _pickupSearchController = TextEditingController();
  final TextEditingController _dropoffSearchController =
      TextEditingController();
  final FocusNode _pickupFocusNode = FocusNode();
  final FocusNode _dropoffFocusNode = FocusNode();

  LatLng _currentCameraPosition = const LatLng(23.8103, 90.4125);
  String _currentAddress = "Loading...";
  bool _isMapReady = false;

  // Live Location
  LatLng? _liveUserLocation;

  // Journey States
  LatLng? _pickupLocation;
  String? _pickupAddress;
  LatLng? _dropoffLocation;
  String? _dropoffAddress;

  // Selection mode: 0 = Pickup, 1 = Drop-off, 2 = Review Route
  int _selectionStep = 0;

  // Routing
  List<LatLng> _routePoints = [];
  String _distanceStr = "";
  String _durationStr = "";
  bool _isLoadingRoute = false;

  // Search States
  List<University> _filteredUniversities = [];
  List<Map<String, dynamic>> _livePlaceSuggestions = [];
  bool _showSuggestions = false;
  bool _isSearchingLive = false;
  Timer? _debounce;

  final List<University> _universities = [
    University(
      name: 'Dhaka University (DU)',
      location: const LatLng(23.7340, 90.3928),
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/e/ee/University_of_Dhaka_logo.svg/1200px-University_of_Dhaka_logo.svg.png',
    ),
    University(
      name: 'BUET',
      location: const LatLng(23.7275, 90.3923),
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/8/87/BUET_LOGO.svg/1200px-BUET_LOGO.svg.png',
    ),
    University(
      name: 'North South University (NSU)',
      location: const LatLng(23.8151, 90.4255),
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/3/30/North_South_University_Monogram.svg/1200px-North_South_University_Monogram.svg.png',
    ),
    University(
      name: 'BRAC University',
      location: const LatLng(23.7788, 90.4265),
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/2/29/BRAC_University_logo.svg/1200px-BRAC_University_logo.svg.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredUniversities = _universities;

    void focusListener() {
      setState(() {
        _showSuggestions =
            _pickupFocusNode.hasFocus || _dropoffFocusNode.hasFocus;
      });
    }

    _pickupFocusNode.addListener(focusListener);
    _dropoffFocusNode.addListener(focusListener);

    _initLiveLocationTracking();
  }

  @override
  void dispose() {
    _pickupSearchController.dispose();
    _dropoffSearchController.dispose();
    _pickupFocusNode.dispose();
    _dropoffFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // --- Swap / Reversal Logic ---
  void _swapLocations() {
    setState(() {
      final tempText = _pickupSearchController.text;
      _pickupSearchController.text = _dropoffSearchController.text;
      _dropoffSearchController.text = tempText;

      final tempLoc = _pickupLocation;
      _pickupLocation = _dropoffLocation;
      _dropoffLocation = tempLoc;

      final tempAddress = _pickupAddress;
      _pickupAddress = _dropoffAddress;
      _dropoffAddress = tempAddress;

      if (_pickupLocation != null && _dropoffLocation != null) {
        _fetchRoute();
      } else if (_pickupLocation != null) {
        _mapController.move(_pickupLocation!, 15.0);
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredUniversities = _universities;
        _livePlaceSuggestions = [];
      } else {
        _filteredUniversities = _universities
            .where((u) => u.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (query.length > 2) {
      _debounce = Timer(const Duration(milliseconds: 600), () {
        _fetchLivePlaceSuggestions(query);
      });
    } else {
      setState(() {
        _livePlaceSuggestions = [];
        _isSearchingLive = false;
      });
    }
  }

  Future<void> _fetchLivePlaceSuggestions(String query) async {
    setState(() => _isSearchingLive = true);
    final url =
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=bd';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'UberClone/1.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _livePlaceSuggestions = data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint("Live Search error: $e");
    } finally {
      setState(() => _isSearchingLive = false);
    }
  }

  void _goToLivePlace(Map<String, dynamic> place) {
    _pickupFocusNode.unfocus();
    _dropoffFocusNode.unfocus();

    final lat = double.parse(place['lat']);
    final lon = double.parse(place['lon']);
    final loc = LatLng(lat, lon);

    String shortName = place['display_name'].split(',')[0];

    setState(() {
      if (_selectionStep == 0) {
        _pickupLocation = loc;
        _pickupAddress = shortName;
        _pickupSearchController.text = shortName;

        if (_dropoffLocation != null) {
          _fetchRoute();
        } else {
          _selectionStep = 1;
          _dropoffFocusNode.requestFocus();
        }
      } else if (_selectionStep == 1) {
        _dropoffLocation = loc;
        _dropoffAddress = shortName;
        _dropoffSearchController.text = shortName;

        if (_pickupLocation != null) {
          _fetchRoute();
        }
      }
      _showSuggestions = false;
    });

    _mapController.move(loc, 15.0);
  }

  void _goToUniversity(University uni) {
    _pickupFocusNode.unfocus();
    _dropoffFocusNode.unfocus();

    setState(() {
      if (_selectionStep == 0) {
        _pickupLocation = uni.location;
        _pickupAddress = uni.name;
        _pickupSearchController.text = uni.name;

        if (_dropoffLocation != null) {
          _fetchRoute();
        } else {
          _selectionStep = 1;
          _dropoffFocusNode.requestFocus();
        }
      } else if (_selectionStep == 1) {
        _dropoffLocation = uni.location;
        _dropoffAddress = uni.name;
        _dropoffSearchController.text = uni.name;

        if (_pickupLocation != null) {
          _fetchRoute();
        }
      }
      _showSuggestions = false;
    });

    _mapController.move(uni.location, 16.0);
  }

  Future<void> _initLiveLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position? initialPos = await Geolocator.getLastKnownPosition();
      initialPos ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      if (initialPos != null && mounted) {
        LatLng liveLoc = LatLng(initialPos.latitude, initialPos.longitude);
        setState(() {
          _liveUserLocation = liveLoc;
          _currentCameraPosition = liveLoc;
        });

        if (_isMapReady) {
          _mapController.move(liveLoc, 14.0);
          _getAddressFromLatLng(liveLoc);
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _isMapReady) {
              _mapController.move(liveLoc, 14.0);
              _getAddressFromLatLng(liveLoc);
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Live Location Fetch Error: $e");
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_liveUserLocation != null) {
      _mapController.move(_liveUserLocation!, 15.0);
      _getAddressFromLatLng(_liveUserLocation!);
    } else {
      _initLiveLocationTracking();
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      setState(() => _currentAddress = "Loading...");
      List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        geo.Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              "${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}"
                  .replaceAll(RegExp(r'^, |, $'), '');
          if (_currentAddress.isEmpty) _currentAddress = "Unnamed Location";

          // --- ম্যাপ ড্র্যাগ করলে অটোমেটিক সার্চ বক্সে লোকেশনের নাম বসে যাবে ---
          if (_selectionStep == 0 && !_pickupFocusNode.hasFocus) {
            _pickupSearchController.text = _currentAddress;
          } else if (_selectionStep == 1 && !_dropoffFocusNode.hasFocus) {
            _dropoffSearchController.text = _currentAddress;
          }
        });
      }
    } catch (e) {
      setState(() => _currentAddress = "Search location...");
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    FocusScope.of(context).unfocus();
    _fetchLivePlaceSuggestions(query);
  }

  Future<void> _fetchRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;
    setState(() {
      _isLoadingRoute = true;
      _selectionStep = 2; // Move to Route View immediately
    });

    final url =
        'http://router.project-osrm.org/route/v1/driving/${_pickupLocation!.longitude},${_pickupLocation!.latitude};${_dropoffLocation!.longitude},${_dropoffLocation!.latitude}?geometries=geojson&alternatives=true';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List routes = data['routes'];

        if (routes.isNotEmpty) {
          routes.sort(
            (a, b) => (a['distance'] as num).compareTo(b['distance'] as num),
          );
          final shortestRoute = routes.first;
          final geometry = shortestRoute['geometry']['coordinates'] as List;
          final dist = shortestRoute['distance'];
          final dur = shortestRoute['duration'];

          setState(() {
            _routePoints = geometry.map((p) => LatLng(p[1], p[0])).toList();
            _distanceStr = (dist / 1000).toStringAsFixed(1) + " km";
            _durationStr = (dur / 60).toStringAsFixed(0) + " mins";
          });

          final bounds = LatLngBounds.fromPoints([
            _pickupLocation!,
            _dropoffLocation!,
          ]);
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
          );
        }
      }
    } catch (e) {
      debugPrint("Routing error: $e");
    } finally {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _handleConfirm() {
    if (_selectionStep == 0) {
      setState(() {
        _pickupLocation = _currentCameraPosition;
        _pickupAddress = _currentAddress;
        _pickupSearchController.text = _pickupAddress ?? '';

        if (_dropoffLocation != null) {
          _fetchRoute();
        } else {
          _selectionStep = 1;
          _dropoffFocusNode.requestFocus();
        }
      });
    } else if (_selectionStep == 1) {
      setState(() {
        _dropoffLocation = _currentCameraPosition;
        _dropoffAddress = _currentAddress;
        _dropoffSearchController.text = _dropoffAddress ?? '';
      });
      _fetchRoute();
    } else if (_selectionStep == 2) {
      Navigator.pop(context, {
        'pickup_address': _pickupAddress,
        'dropoff_address': _dropoffAddress,
        'distance': _distanceStr,
        'duration': _durationStr,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: GestureDetector(
        onTap: () {
          _pickupFocusNode.unfocus();
          _dropoffFocusNode.unfocus();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // --- Map Layer ---
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCameraPosition,
                initialZoom: 15.0,
                onMapReady: () {
                  setState(() => _isMapReady = true);
                  if (_liveUserLocation != null) {
                    _mapController.move(_liveUserLocation!, 15.0);
                    _getAddressFromLatLng(_liveUserLocation!);
                  }
                },
                onPositionChanged: (MapCamera camera, bool hasGesture) {
                  if (hasGesture && _selectionStep != 2) {
                    setState(() => _currentCameraPosition = camera.center);
                    FocusScope.of(context).unfocus();
                  }
                },
                onMapEvent: (MapEvent event) {
                  if (event is MapEventMoveEnd && _selectionStep != 2) {
                    _getAddressFromLatLng(_currentCameraPosition);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.yourapp.name',
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 4.0,
                        color: Colors.black,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    ..._universities.map(
                      (uni) => Marker(
                        point: uni.location,
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _goToUniversity(uni),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black,
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                            ),
                            padding: const EdgeInsets.all(2),
                            child: ClipOval(
                              child: Image.network(
                                uni.logoUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.school, size: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_liveUserLocation != null)
                      Marker(
                        point: _liveUserLocation!,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5),
                            ],
                          ),
                        ),
                      ),

                    // --- ম্যাপে সিলেক্ট হওয়া লোকেশনে পিন এবং নাম দেখাবে ---
                    if (_pickupLocation != null)
                      _buildSleekLabeledMarker(
                        _pickupLocation!,
                        'Pickup',
                        true,
                      ),
                    if (_dropoffLocation != null)
                      _buildSleekLabeledMarker(
                        _dropoffLocation!,
                        'Drop-off',
                        false,
                      ),
                  ],
                ),
              ],
            ),

            // --- Center Pin ---
            if (_selectionStep != 2)
              const Padding(
                padding: EdgeInsets.only(bottom: 35.0),
                child: Icon(Icons.location_pin, size: 40, color: Colors.black),
              ),

            // --- Uber Search Bar with Swap Button ---
            Positioned(
              top: 55,
              left: 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.black87,
                                width: 2.5,
                              ),
                            ),
                          ),
                          Container(
                            width: 1.5,
                            height: 38,
                            color: Colors.black87,
                          ),
                          Container(width: 8, height: 8, color: Colors.black87),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _pickupSearchController,
                            focusNode: _pickupFocusNode,
                            onTap: () {
                              setState(() {
                                _selectionStep = 0;
                                _routePoints.clear();
                              });
                            },
                            onChanged: _onSearchChanged,
                            onSubmitted: _searchPlace,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Pickup',
                              hintStyle: TextStyle(
                                color: subtitleColor,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              suffixIcon:
                                  _pickupSearchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _pickupSearchController.clear();
                                          _pickupLocation = null;
                                          _pickupAddress = null;
                                          _routePoints.clear();
                                          _selectionStep = 0;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                          Container(height: 1, color: Colors.grey.shade200),
                          TextField(
                            controller: _dropoffSearchController,
                            focusNode: _dropoffFocusNode,
                            onTap: () {
                              setState(() {
                                _selectionStep = 1;
                                _routePoints.clear();
                              });
                            },
                            onChanged: _onSearchChanged,
                            onSubmitted: _searchPlace,
                            textInputAction: TextInputAction.search,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Drop-off',
                              hintStyle: TextStyle(
                                color: subtitleColor,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              suffixIcon:
                                  _dropoffSearchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.clear,
                                        color: Colors.grey,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _dropoffSearchController.clear();
                                          _dropoffLocation = null;
                                          _dropoffAddress = null;
                                          _routePoints.clear();
                                          _selectionStep = 1;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Swap Option
                    GestureDetector(
                      onTap: _swapLocations,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.swap_vert,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Uber Search Suggestions ---
            if (_showSuggestions)
              Positioned(
                top: 170,
                left: 16,
                right: 16,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      children: [
                        if (_filteredUniversities.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 8,
                              bottom: 4,
                            ),
                            child: Text(
                              "UNIVERSITIES",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          ..._filteredUniversities.map(
                            (uni) => ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(uni.logoUrl),
                                  radius: 12,
                                ),
                              ),
                              title: Text(
                                uni.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onTap: () => _goToUniversity(uni),
                            ),
                          ),
                        ],
                        if (_livePlaceSuggestions.isNotEmpty ||
                            _isSearchingLive) ...[
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 12,
                              bottom: 4,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "PLACES",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                if (_isSearchingLive)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          ..._livePlaceSuggestions.map((place) {
                            List<String> nameParts = place['display_name']
                                .split(',');
                            String title = nameParts[0];
                            String subtitle = nameParts
                                .skip(1)
                                .join(',')
                                .trim();
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: subtitleColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _goToLivePlace(place),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

            // --- Current Location Button ---
            if (_selectionStep != 2)
              Positioned(
                bottom: 150,
                right: 16,
                child: GestureDetector(
                  onTap: _moveToCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
              ),

            // --- Clean Bottom Panel ---
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectionStep != 2) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_pin,
                            color: Colors.black,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currentAddress,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      // Route Review Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRouteInfo("Distance", _distanceStr),
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey.shade300,
                          ),
                          _buildRouteInfo("Time", _durationStr),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Black Uber Confirm Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoadingRoute ? null : _handleConfirm,
                        child: _isLoadingRoute
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _selectionStep == 0
                                    ? 'Confirm Pickup'
                                    : _selectionStep == 1
                                    ? 'Confirm Drop-off'
                                    : 'Confirm Ride',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BACK BUTTON IN REVIEW ROUTE ---
            if (_selectionStep == 2)
              Positioned(
                top: 50,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectionStep = 1; // Go back to drop-off step
                      _routePoints.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- ম্যাপের উপরে লোকেশনের টেক্সট (Pickup/Drop-off) দেখানোর জন্য আপডেট করা মার্কার ---
  Marker _buildSleekLabeledMarker(LatLng point, String label, bool isPickup) {
    return Marker(
      point: point,
      width: 80,
      height: 70,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPickup ? Colors.black : Colors.black87,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Icon(
            Icons.location_pin,
            color: isPickup ? Colors.black : Colors.black87,
            size: 35,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
