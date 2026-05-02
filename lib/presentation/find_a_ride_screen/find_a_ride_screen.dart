import '../../core/app_export.dart';
import './widgets/female_only_banner_widget.dart';
import './widgets/ride_card_widget.dart';
import './widgets/sort_filter_bar_widget.dart';
import './widgets/vehicle_type_filter_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FindARideScreen extends StatefulWidget {
  const FindARideScreen({super.key});

  @override
  State<FindARideScreen> createState() => _FindARideScreenState();
}

// TODO: Replace with Riverpod/Bloc for production
class _FindARideScreenState extends State<FindARideScreen>
    with TickerProviderStateMixin {
  int _selectedNavIndex = 0;
  int _selectedSortIndex = 0;
  String _selectedVehicleType = 'All';
  // ignore: unused_field
  bool _isLoading = false;

  late List<AnimationController> _cardAnimControllers;
  late List<Animation<Offset>> _cardSlideAnimations;
  late List<Animation<double>> _cardFadeAnimations;


  @override
  void initState() {
    super.initState();
    _cardAnimControllers = [];
    _cardSlideAnimations = [];
    _cardFadeAnimations = [];
  }

  void _initAnimations(int rideCount) {
    _cardAnimControllers = List.generate(
      rideCount,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 350 + (i * 60)),
      ),
    );
    _cardSlideAnimations = _cardAnimControllers.map((ctrl) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic));
    }).toList();
    _cardFadeAnimations = _cardAnimControllers.map((ctrl) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: ctrl, curve: Curves.easeOut));
    }).toList();
  }

  void _startEntranceAnimation() async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (int i = 0; i < _cardAnimControllers.length; i++) {
      await Future.delayed(Duration(milliseconds: i * 80));
      if (mounted) _cardAnimControllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final ctrl in _cardAnimControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }



  void _onNavTap(int index) {
    // TODO: Replace with Riverpod/Bloc for production
    if (index == 2) {
      Navigator.pushNamed(context, AppRoutes.postARideScreen);
      return;
    }
    setState(() => _selectedNavIndex = index);
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      for (final ctrl in _cardAnimControllers) {
        if (ctrl.isAnimating) ctrl.reset();
      }
      _startEntranceAnimation();
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Login screen-e pathiye dibe
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.loginScreen,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: isTablet
            ? Row(
                children: [
                  AppNavigation(
                    currentIndex: _selectedNavIndex,
                    onTap: _onNavTap,
                  ),
                  Expanded(child: _buildBody(theme, isTablet)),
                ],
              )
            : _buildBody(theme, isTablet),
      ),
      bottomNavigationBar: isTablet
          ? null
          : AppNavigation(currentIndex: _selectedNavIndex, onTap: _onNavTap),
    );
  }

  Widget _buildBody(ThemeData theme, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAppBar(theme),
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('rides').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No rides available"));
              }

              final rides = snapshot.data!.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                _initAnimations(snapshot.data!.docs.length);

                return {
                  'id': doc.id,
                  'driverName': "Driver",
                  'driverInitial': "D",
                  'rating': 4.5,
                  'totalRides': 10,
                  'currency': '৳',

                  'fromLocation': data['fromLocation'] ?? '',
                  'toLocation': data['toLocation'] ?? '',
                  'pricePerSeat': data['pricePerSeat'] ?? 0,
                  'seatsLeft': data['availableSeats'] ?? 0,
                  'totalSeats': data['totalSeats'] ?? 0,
                  'vehicleModel': data['vehicleModel'] ?? '',
                  'vehicleType': data['vehicleType'] ?? '',
                  'hasAC': data['hasAC'] ?? false,
                  'isFemaleOnly': data['isFemaleOnly'] ?? false,

                  'stops': (data['stops'] ?? []).length,
                  'departureDate': "Today",
                  'departureTime': "Soon",
                  'distance': 0.0,
                  'notes': '',
                  'isTopRated': false,
                };
              }).toList();

              return ListView.builder(
                itemCount: rides.length,
                itemBuilder: (context, index) {
                  return _buildAnimatedCard(rides, index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedCard(List<Map<String, dynamic>> rides, int index) {
    if (index >= _cardAnimControllers.length) {
      return RideCardWidget(
        rideData: rides[index],
        onDetailsPressed: () => Navigator.pushNamed(
          context,
          AppRoutes.rideDetailScreen,
          arguments: rides[index],
        ),
        onBookPressed: () => _showBookingConfirmation(rides[index]),
      );
    }
    return SlideTransition(
      position: _cardSlideAnimations[index],
      child: FadeTransition(
        opacity: _cardFadeAnimations[index],
        child: RideCardWidget(
          rideData: rides[index],
          onDetailsPressed: () => Navigator.pushNamed(
            context,
            AppRoutes.rideDetailScreen,
            arguments: rides[index],
          ),
          onBookPressed: () => _showBookingConfirmation(rides[index]),
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryDark, AppTheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'RideShare',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Find a Ride',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons (Notification, Profile/Logout, Filter)
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                ),
              ),
              // User Avatar with Popup Menu
              PopupMenuButton<int>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 2) _handleLogout();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text('My Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Logout',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(100),
                      width: 1.5,
                    ),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?u=nadia'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _FilterButton(),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmation(Map<String, dynamic> ride) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookingBottomSheet(ride: ride),
    );
  }
}

class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(77)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.tune_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text(
              'Filters',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingBottomSheet extends StatefulWidget {
  final Map<String, dynamic> ride;

  const _BookingBottomSheet({required this.ride});

  @override
  State<_BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<_BookingBottomSheet> {
  int _seats = 1;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ride = widget.ride;
    final maxSeats = ride['seatsLeft'] as int;
    final pricePerSeat = ride['pricePerSeat'] as int;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.cardBorder,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Confirm Booking', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${ride['fromLocation']} → ${ride['toLocation']}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Seats', style: theme.textTheme.titleSmall),
              Row(
                children: [
                  _SeatButton(
                    icon: Icons.remove_rounded,
                    onTap: _seats > 1 ? () => setState(() => _seats--) : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_seats',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _SeatButton(
                    icon: Icons.add_rounded,
                    onTap: _seats < maxSeats
                        ? () => setState(() => _seats++)
                        : null,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: theme.textTheme.titleSmall),
                Text(
                  '${ride['currency']}${pricePerSeat * _seats}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.priceGreen,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isBooking ? null : _confirmBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isBooking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      'Confirm Booking',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBooking() async {
    setState(() => _isBooking = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking confirmed! $_seats seat${_seats > 1 ? 's' : ''} reserved.',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

class _SeatButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SeatButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppTheme.primaryContainer
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: onTap != null ? AppTheme.primary : AppTheme.muted,
        ),
      ),
    );
  }
}
