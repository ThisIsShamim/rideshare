import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RideRequestDetailsShow extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onNewPressed;
  final VoidCallback? onRequestFirstRide;

  /// If set, only this user's ride requests are loaded.
  final String? currentUserId;

  const RideRequestDetailsShow({
    super.key,
    this.onBackPressed,
    this.onNewPressed,
    this.onRequestFirstRide,
    this.currentUserId,
  });

  @override
  State<RideRequestDetailsShow> createState() => _RideRequestDetailsShowState();
}

class _RideRequestDetailsShowState extends State<RideRequestDetailsShow> {
  int _selectedTabIndex = 0;
  final List<String> _tabLabels = ['All', 'Pending', 'Accepted', 'Declined'];

  Stream<QuerySnapshot<Map<String, dynamic>>> _rideRequestsStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('ride_request')
        .orderBy('created_at', descending: true);

    if (widget.currentUserId != null && widget.currentUserId!.isNotEmpty) {
      query = query.where('userId', isEqualTo: widget.currentUserId);
    }

    return query.snapshots();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> all(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) => docs;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> pending(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) => docs.where((doc) => _statusOf(doc) == 'pending').toList();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> accepted(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) => docs.where((doc) => _statusOf(doc) == 'accepted').toList();

  List<QueryDocumentSnapshot<Map<String, dynamic>>> declined(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) => docs.where((doc) => _statusOf(doc) == 'declined').toList();

  String _statusOf(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return (doc.data()['status'] ?? 'pending').toString().toLowerCase();
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterByTab(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    switch (_selectedTabIndex) {
      case 1:
        return pending(docs);
      case 2:
        return accepted(docs);
      case 3:
        return declined(docs);
      default:
        return all(docs);
    }
  }

  int _countForTab(
    int index,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    switch (index) {
      case 1:
        return pending(docs).length;
      case 2:
        return accepted(docs).length;
      case 3:
        return declined(docs).length;
      default:
        return all(docs).length;
    }
  }

  Future<void> _cancelRequest(String docId) async {
    await FirebaseFirestore.instance
        .collection('ride_request')
        .doc(docId)
        .update({'status': 'declined'});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _rideRequestsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Error loading data',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final filtered = _filterByTab(allDocs);

                  return Column(
                    children: [
                      _buildSubtitle(allDocs.length),
                      _buildTabs(allDocs),
                      const SizedBox(height: 8),
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState(allDocs.isEmpty)
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  24,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final doc = filtered[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: _buildRideCard(doc.id, doc.data()),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(int totalCount) {
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 16, bottom: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$totalCount total request${totalCount == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () {
                if (widget.onBackPressed != null) {
                  widget.onBackPressed!();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'My Ride Requests',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: widget.onNewPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text(
              'New',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabLabels.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedTabIndex == index;
          final count = _countForTab(index, allDocs);
          final label = '${_tabLabels[index]} ($count)';

          return GestureDetector(
            onTap: () => setState(() => _selectedTabIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool noRequestsAtAll) {
    final tabName = _tabLabels[_selectedTabIndex].toLowerCase();
    final message = noRequestsAtAll
        ? 'No requests yet'
        : 'No $tabName requests';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                size: 40,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (noRequestsAtAll) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onRequestFirstRide ?? widget.onNewPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Request Your First Ride',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRideCard(String docId, Map<String, dynamic> data) {
    final pickup = data['pickup_location']?.toString() ?? 'Unknown';
    final dropoff = data['dropoff_location']?.toString() ?? 'Unknown';
    final price = data['max_price'] ?? 0;
    final passengers = data['passengers'] ?? 1;
    final status = (data['status'] ?? 'pending').toString().toLowerCase();
    final notes = data['notes']?.toString() ?? '';

    final createdAt =
        (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now();
    final rideTime =
        (data['ride_time'] as Timestamp?)?.toDate() ?? DateTime.now();

    final formattedCreatedAt = DateFormat('MMM d, h:mm a').format(createdAt);
    final formattedRideDate = DateFormat('MMM d').format(rideTime);
    final formattedRideTime = DateFormat('h:mm a').format(rideTime);

    Color headerColor = Colors.orange.shade500;
    String statusText = 'Waiting for driver';
    IconData statusIcon = Icons.hourglass_bottom;

    if (status == 'accepted') {
      headerColor = Colors.green.shade600;
      statusText = 'Ride Accepted';
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'declined') {
      headerColor = Colors.red.shade500;
      statusText = 'Ride Declined';
      statusIcon = Icons.cancel_outlined;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: headerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  formattedCreatedAt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.near_me_outlined,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        pickup,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dropoff,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoBox(
                        Icons.access_time,
                        formattedRideDate,
                        formattedRideTime,
                        Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBox(
                        Icons.people_outline,
                        '$passengers',
                        'seats',
                        Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoBox(
                        Icons.payments_outlined,
                        '৳$price',
                        'max',
                        Colors.green.shade50,
                        iconColor: Colors.teal,
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Text(
                      notes,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelRequest(docId),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.red.shade200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        'Cancel Request',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(
    IconData icon,
    String title,
    String subtitle,
    Color bgColor, {
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor ?? Colors.grey.shade600),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: iconColor != null ? Colors.teal.shade800 : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: iconColor != null
                  ? Colors.teal.shade600
                  : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
