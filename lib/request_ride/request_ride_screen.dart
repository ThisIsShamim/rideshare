import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Date format korar jonno

class RequestRideScreen extends StatefulWidget {
  const RequestRideScreen({super.key});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

class _RequestRideScreenState extends State<RequestRideScreen> {
  int _passengerCount = 1;
  int _maxPrice = 150;

  // State variables for inputs
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<int> _priceOptions = [50, 100, 150, 200, 250];

  @override
  void initState() {
    super.initState();
    // Text input change hole jeno nicher summary box aur button update hoy
    _pickupController.addListener(() => setState(() {}));
    _dropoffController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  // Validation Check: Pickup, Drop-off, Date, Time shob fill kora ache kina
  bool get _isFormValid {
    return _pickupController.text.trim().isNotEmpty &&
        _dropoffController.text.trim().isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null;
  }

  // Date aur Time picker funciton
  Future<void> _pickDateTime() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedDate = date;
          _selectedTime = time;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Home Screen er moto same AppBar
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackHeader(),
            const SizedBox(height: 16),
            _buildInfoBanner(),
            const SizedBox(height: 20),
            _buildJourneyCard(),
            const SizedBox(height: 16),
            _buildDateTimeAndPassengerCard(),
            const SizedBox(height: 16),
            _buildPriceCard(),
            const SizedBox(height: 16),
            _buildNotesCard(),
            const SizedBox(height: 20),

            // Updated Summary Box
            _buildRequestSummary(),
            const SizedBox(height: 16),

            // Send Request Button (Condition Applied)
            _buildSendRequestButton(),

            const SizedBox(height: 40), // For bottom spacing
          ],
        ),
      ),
      // Home Screen er moto same Floating Action Button aur Bottom Nav
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A69FF),
        shape: const CircleBorder(),
        onPressed: () {
          // Home page e back korar jonno
          Navigator.pop(context);
        },
        child: const Icon(Icons.home, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- Same AppBar as Home Screen ---
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false, // Default back button hide kora hoyeche
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

  // --- Same Bottom Nav as Home Screen ---
  Widget _buildBottomNav(BuildContext context) {
    return BottomAppBar(
      elevation: 15,
      shadowColor: Colors.black45,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(Icons.home, "Search", false, () {
                    Navigator.pop(context); // Home e jabe
                  }),
                  _buildNavItem(Icons.format_list_bulleted, "Rides", false, () {
                    // Rides route e jabe
                  }),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Home',
                  style: TextStyle(color: Colors.grey[500], fontSize: 10),
                ),
                const SizedBox(height: 4),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    Icons.inbox_outlined,
                    "Requests",
                    true,
                    () {},
                  ), // Currently in Request page
                  _buildNavItem(Icons.person_outline, "Profile", false, () {
                    // Profile route e jabe
                  }),
                ],
              ),
            ),
          ],
        ),
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

  // --- Baki UI Widgets (Ager motoi thakbe) ---

  Widget _buildBackHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Request a Ride",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "Find drivers going your way",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD2E3FC)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Color(0xFF1A73E8), size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How it works",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A73E8),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Post your ride request and nearby available drivers will be notified. They can accept your request and contact you directly.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1A73E8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard() {
    return _buildSectionCard(
      title: "YOUR JOURNEY",
      child: Column(
        children: [
          _buildLocationInput(
            Icons.near_me,
            "PICKUP LOCATION",
            "Where are you now?",
            Colors.blue,
            _pickupController,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 1,
                height: 20,
                color: Colors.grey.shade300,
              ),
            ),
          ),
          _buildLocationInput(
            Icons.location_on,
            "DROP-OFF LOCATION",
            "Where do you want to go?",
            Colors.green,
            _dropoffController,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput(
    IconData icon,
    String label,
    String hint,
    Color iconColor,
    TextEditingController controller,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor,
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeAndPassengerCard() {
    return _buildSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, color: Color(0xFF1A69FF), size: 20),
              const SizedBox(width: 12),
              const Text(
                "When do you need it?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickDateTime,
            child: Container(
              height: 45,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                _selectedDate != null && _selectedTime != null
                    ? "${DateFormat('dd MMM, yyyy').format(_selectedDate!)} at ${_selectedTime!.format(context)}"
                    : "Select Date and Time",
                style: TextStyle(
                  color: _selectedDate != null
                      ? Colors.black87
                      : Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: _selectedDate != null
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Color(0xFF1A69FF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Number of Passengers",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildCountButton(
                    Icons.remove,
                    () => setState(
                      () => _passengerCount > 1 ? _passengerCount-- : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "$_passengerCount",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildCountButton(
                    Icons.add,
                    () => setState(() => _passengerCount++),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCountButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildPriceCard() {
    return _buildSectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  color: Colors.green,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Maximum Price",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCountButton(
                Icons.remove,
                () => setState(() => _maxPrice > 10 ? _maxPrice -= 10 : null),
              ),
              Text(
                "৳$_maxPrice",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00B14F),
                ),
              ),
              _buildCountButton(
                Icons.add,
                () => setState(() => _maxPrice += 10),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _priceOptions.map((price) {
              bool isSelected = _maxPrice == price;
              return GestureDetector(
                onTap: () => setState(() => _maxPrice = price),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00B14F)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "৳$price",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return _buildSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Additional Notes (optional)",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Any special requirements or preferences...",
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestSummary() {
    String pickupStr = _pickupController.text.isEmpty
        ? "—"
        : _pickupController.text;
    String dropoffStr = _dropoffController.text.isEmpty
        ? "—"
        : _dropoffController.text;

    String dateTimeStr = "—";
    if (_selectedDate != null && _selectedTime != null) {
      final combinedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      dateTimeStr = DateFormat('MMM d, yyyy, h:mm a').format(combinedDateTime);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A69FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "REQUEST SUMMARY",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.near_me_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "$pickupStr  →  $dropoffStr",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateTimeStr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "$_passengerCount seat",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Max ৳$_maxPrice",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSendRequestButton() {
    bool isValid = _isFormValid;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isValid
            ? () {
                // TODO: Firebase e request send korar logic ekhane thakbe
                print("Request Sending...");
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid
              ? const Color(0xFF1A69FF)
              : Colors.grey.shade100,
          disabledBackgroundColor: Colors.grey.shade100,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: Icon(
          Icons.send_outlined,
          color: isValid ? Colors.white : Colors.grey.shade500,
          size: 18,
        ),
        label: Text(
          "Send Ride Request",
          style: TextStyle(
            color: isValid ? Colors.white : Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
