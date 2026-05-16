import 'package:flutter/material.dart';

class VerificationDialogs {
  // --- বিশাল ইউনিভার্সিটির লিস্ট ---
  static final List<String> universities = [
    // Public Universities
    "University of Dhaka (DU)",
    "Bangladesh University of Engineering and Technology (BUET)",
    "Jahangirnagar University (JU)",
    "Rajshahi University (RU)",
    "Chittagong University (CU)",
    "Shahjalal University of Science and Technology (SUST)",
    "Khulna University (KU)",
    "Khulna University of Engineering & Technology (KUET)",
    "Rajshahi University of Engineering & Technology (RUET)",
    "Chittagong University of Engineering & Technology (CUET)",
    "Dhaka University of Engineering & Technology (DUET)",
    "Bangladesh Textile University (BUTEX)",
    "Bangladesh Agricultural University (BAU)",
    "Jagannath University (JnU)",
    "Comilla University (CoU)",
    "Jatiya Kabi Kazi Nazrul Islam University (JKKNIU)",
    "Begum Rokeya University, Rangpur (BRUR)",
    "Barisal University (BU)",
    "Bangabandhu Sheikh Mujibur Rahman Science and Technology University (BSMRSTU)",
    "Bangladesh University of Professionals (BUP)",
    "Military Institute of Science and Technology (MIST)",
    "Noakhali Science and Technology University (NSTU)",
    "Pabna University of Science and Technology (PUST)",
    "Hajee Mohammad Danesh Science & Technology University (HSTU)",
    "Patuakhali Science and Technology University (PSTU)",
    "Sylhet Agricultural University (SAU)",
    "Sher-e-Bangla Agricultural University (SAU)",
    "Chittagong Veterinary and Animal Sciences University (CVASU)",
    "Jessore University of Science & Technology (JUST)",
    "Mawlana Bhashani Science and Technology University (MBSTU)",
    "Islamic University (IU)",
    "National University, Bangladesh (NU)",
    "Bangladesh Open University (BOU)",

    // Private Universities
    "North South University (NSU)",
    "BRAC University (BRACU)",
    "American International University-Bangladesh (AIUB)",
    "Independent University, Bangladesh (IUB)",
    "East West University (EWU)",
    "Ahsanullah University of Science and Technology (AUST)",
    "United International University (UIU)",
    "Daffodil International University (DIU)",
    "University of Liberal Arts Bangladesh (ULAB)",
    "Green University of Bangladesh (GUB)",
    "Stamford University Bangladesh",
    "Southeast University (SEU)",
    "State University of Bangladesh (SUB)",
    "City University",
    "Primeasia University",
    "Bangladesh University",
    "Northern University Bangladesh (NUB)",
    "Southern University Bangladesh",
    "Premier University",
    "International Islamic University Chittagong (IIUC)",
    "Varendra University",
    "Notre Dame University Bangladesh (NDUB)",
    "Canadian University of Bangladesh (CUB)",
    "International University of Business Agriculture and Technology (IUBAT)",
    "Bangladesh University of Business and Technology (BUBT)",
    "Leading University (LU)",
    "East Delta University (EDU)",
    "Chittagong Independent University (CIU)",
    "University of Asia Pacific (UAP)",
    "World University of Bangladesh (WUB)",
    "Eastern University (EU)",
    "Presidency University (PU)",
    "ASA University Bangladesh (ASAUB)",
    "Z.H. Sikder University of Science and Technology (ZHSUST)",
    "Feni University",
    "Fareast International University",
    "Sonargaon University",
    "European University of Bangladesh (EUB)",
    "BGMEA University of Fashion & Technology (BUFT)",

    // Medical Colleges
    "Dhaka Medical College (DMC)",
    "Sir Salimullah Medical College (SSMC)",
    "Shaheed Suhrawardy Medical College (ShSMC)",
    "Mymensingh Medical College (MMC)",
    "Chittagong Medical College (CMC)",
    "Rajshahi Medical College (RMC)",
    "Sylhet MAG Osmani Medical College (SOMC)",
    "Sher-e-Bangla Medical College (SBMC)",
  ];

  // --- বিশাল ডিপার্টমেন্টের লিস্ট ---
  static final List<String> departments = [
    "Computer Science & Engineering (CSE)",
    "Electrical & Electronic Engineering (EEE)",
    "Mechanical Engineering (ME)",
    "Civil Engineering (CE)",
    "Architecture",
    "Software Engineering (SE)",
    "Information Technology (IT)",
    "Textile Engineering",
    "Industrial & Production Engineering (IPE)",
    "Electronics & Telecommunication Engineering (ETE)",
    "Information & Communication Engineering (ICE)",
    "Bachelor of Business Administration (BBA)",
    "Master of Business Administration (MBA)",
    "Accounting & Information Systems",
    "Finance & Banking",
    "Marketing",
    "Management",
    "Pharmacy",
    "Physics",
    "Chemistry",
    "Mathematics",
    "English",
    "Economics",
    "Law (LLB/LLM)",
    "MBBS",
    "BDS (Dental)",
    "Nursing",
  ];

  // --- USER VERIFICATION DIALOG ---
  static void showUserVerification(BuildContext context) {
    TextEditingController uniController = TextEditingController();
    TextEditingController deptController = TextEditingController();
    String? selectedRole;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF828282),
                          size: 22,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2F80ED).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Color(0xFF2F80ED),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "User Verification Required",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Verify your identity to book or post rides safely",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF828282)),
                    ),
                    const SizedBox(height: 24),

                    _buildFieldLabel("I am a *"),
                    _buildRoleDropdown(
                      value: selectedRole,
                      hint: "Select your role",
                      onChanged: (val) {
                        setModalState(() {
                          selectedRole = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel("University *"),
                    _buildBottomSheetSelector(
                      hint: "Select your university",
                      value: uniController.text,
                      onTap: () {
                        _showSearchBottomSheet(
                          context: context,
                          title: "Search University",
                          allItems: universities,
                          mainController: uniController,
                          onSelected: () => setModalState(() {}),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel("Department *"),
                    _buildBottomSheetSelector(
                      hint: "Select your department",
                      value: deptController.text,
                      onTap: () {
                        _showSearchBottomSheet(
                          context: context,
                          title: "Search Department",
                          allItems: departments,
                          mainController: deptController,
                          onSelected: () => setModalState(() {}),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              (selectedRole != null &&
                                  uniController.text.isNotEmpty &&
                                  deptController.text.isNotEmpty)
                              ? const Color(0xFF2F80ED)
                              : const Color(0xFF828282),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- DRIVER VERIFICATION DIALOG ---
  static void showDriverVerification(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFF4F8FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_filled_rounded,
                  color: Color(0xFF2F80ED),
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Driver Verification",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Complete verification to start posting rides",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF828282)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1724),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Start Verification",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---
  static Widget _buildFieldLabel(String label) {
    bool hasAsterisk = label.contains('*');
    String text = label.replaceAll('*', '').trim();
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            children: hasAsterisk
                ? [
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }

  // --- UPDATED: Role Dropdown (Student, Faculty etc) ---
  static Widget _buildRoleDropdown({
    required String? value,
    required String hint,
    required Function(String?) onChanged,
  }) {
    final List<Map<String, String>> roles = [
      {'icon': '🎓', 'title': 'Student'},
      {'icon': '👩‍🏫', 'title': 'Faculty Member'},
      {'icon': '👔', 'title': 'Staff Member'},
    ];

    bool isSelected = value != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          // সিলেক্ট হলে বর্ডারটা হালকা নীল হবে (একটু ফোকাসড দেখানোর জন্য)
          color: isSelected
              ? const Color(0xFF2F80ED).withOpacity(0.3)
              : const Color(0xFFF2F2F2),
        ),
      ),
      height: 50,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          // --- এখানে আইকন চেঞ্জ করার লজিক দেওয়া হয়েছে ---
          icon: isSelected
              ? const Icon(
                  Icons.check_circle,
                  color: Color(0xFF219653),
                  size: 20,
                ) // সবুজ চেকমার্ক
              : const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFFBDBDBD),
                ), // নরমাল অ্যারো
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 13, color: Color(0xFFBDBDBD)),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: roles.map((role) {
            return DropdownMenuItem<String>(
              value: role['title'],
              child: Row(
                children: [
                  Text(role['icon']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  Text(
                    role['title']!,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF333333),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- UPDATED: Bottom Sheet Selector ---
  static Widget _buildBottomSheetSelector({
    required String hint,
    required String value,
    required VoidCallback onTap,
  }) {
    bool isSelected = value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            // সিলেক্ট হলে বর্ডারটা হালকা নীল হবে
            color: isSelected
                ? const Color(0xFF2F80ED).withOpacity(0.3)
                : const Color(0xFFF2F2F2),
          ),
        ),
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                isSelected ? value : hint,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? const Color(0xFF333333)
                      : const Color(0xFFBDBDBD),
                  fontWeight: isSelected
                      ? FontWeight.w500
                      : FontWeight.normal, // সিলেক্ট হলে একটু বোল্ড হবে
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // --- এখানে আইকন চেঞ্জ করার লজিক ---
            isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: Color(0xFF219653),
                    size: 20,
                  ) // সবুজ চেকমার্ক
                : const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFFBDBDBD),
                  ), // নরমাল অ্যারো
          ],
        ),
      ),
    );
  }

  // Search Bottom Sheet (একই থাকছে)
  static void _showSearchBottomSheet({
    required BuildContext context,
    required String title,
    required List<String> allItems,
    required TextEditingController mainController,
    required VoidCallback onSelected,
  }) {
    TextEditingController searchController = TextEditingController();
    List<String> filteredItems = List.from(allItems);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFF828282),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setSheetState(() {
                          filteredItems = allItems
                              .where(
                                (item) => item.toLowerCase().contains(
                                  val.toLowerCase(),
                                ),
                              )
                              .toList();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search",
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF828282),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF9FAFC),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF2F2F2),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF2F2F2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F80ED),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filteredItems.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Color(0xFFF2F2F2)),
                      itemBuilder: (context, index) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          title: Text(
                            filteredItems[index],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                          ),
                          onTap: () {
                            mainController.text = filteredItems[index];
                            onSelected();
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
