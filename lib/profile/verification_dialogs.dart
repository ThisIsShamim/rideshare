import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class VerificationDialogs {
  // --- bishal university list ---
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
    "International Islamic University Chancellor (IIUC)",
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

  // --- bishal department list ---
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
    TextEditingController idController = TextEditingController();
    String? selectedRole;
    int currentPage = 1; // 1: Info & Selection, 2: ID & Upload
    String? pickedFileName; 

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isStudent = selectedRole == 'Student';
            String idLabelText =
                isStudent ? "Student ID Number *" : "Job ID Number *";
            String idHintText =
                isStudent ? "e.g., 2021-1-60-001" : "e.g., FAC-2023-001";
            String uploadHintText =
                isStudent ? "Click to upload Student ID" : "Click to upload Job ID";

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 24,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close Button
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
                      const SizedBox(height: 8),

                      // Shield Icon
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

                      // Title
                      const Text(
                        "User Verification Required",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      const Text(
                        "Verify your identity to book or post rides safely",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF828282),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (currentPage == 1) ...[
                        // Info Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80ED).withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF2F80ED).withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Why verify?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2F80ED),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              _buildCheckItem("Build trust with other users"),
                              _buildCheckItem("Access to all RideShare features"),
                              _buildCheckItem("Enhanced safety for everyone"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Role Dropdown (Updated as per screenshot)
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

                        // University Selector (Updated as per screenshot)
                        _buildFieldLabel("University *"),
                        _buildBottomSheetSelector(
                          hint: "Search your university...",
                          value: uniController.text,
                          onTap: () {
                            _showSearchBottomSheet(
                              context: context,
                              title: "Search University",
                              allItems: universities,
                              mainController: uniController,
                              onSelected: () {
                                setModalState(() {});
                              },
                            );
                          },
                        ),
                        if (uniController.text.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF219653),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Selected ${uniController.text}",
                                  style: const TextStyle(
                                    color: Color(0xFF219653),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Department Selector (Updated as per screenshot)
                        _buildFieldLabel("Department *"),
                        _buildBottomSheetSelector(
                          hint: "Search your department...",
                          value: deptController.text,
                          onTap: () {
                            _showSearchBottomSheet(
                              context: context,
                              title: "Search Department",
                              allItems: departments,
                              mainController: deptController,
                              onSelected: () {
                                setModalState(() {});
                              },
                            );
                          },
                        ),
                        if (deptController.text.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF219653),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Selected ${deptController.text}",
                                  style: const TextStyle(
                                    color: Color(0xFF219653),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 24),

                        // Continue Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: (selectedRole != null &&
                                    uniController.text.isNotEmpty &&
                                    deptController.text.isNotEmpty)
                                ? () {
                                    setModalState(() {
                                      currentPage = 2;
                                    });
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF070B19),
                              disabledBackgroundColor: const Color(0xFFE0E0E0),
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
                      ] else ...[
                        // ID Input Field
                        _buildFieldLabel(idLabelText),
                        TextField(
                          controller: idController,
                          onChanged: (val) {
                            setModalState(() {});
                          },
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF333333),
                          ),
                          decoration: _buildInputDecoration(idHintText),
                        ),
                        const SizedBox(height: 16),

                        // File Upload Card
                        _buildFieldLabel("Upload ID Card *"),
                        GestureDetector(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                            );
                            if (result != null) {
                              setModalState(() {
                                pickedFileName = result.files.single.name;
                              });
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: pickedFileName != null
                                    ? const Color(0xFF219653)
                                    : const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  pickedFileName != null
                                      ? Icons.check_circle_outline
                                      : Icons.upload_file_outlined,
                                  size: 32,
                                  color: pickedFileName != null
                                      ? const Color(0xFF219653)
                                      : const Color(0xFF828282),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pickedFileName ?? uploadHintText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: pickedFileName != null
                                        ? const Color(0xFF219653)
                                        : const Color(0xFF828282),
                                    fontWeight: pickedFileName != null
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFE0E0E0),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      currentPage = 1;
                                    });
                                  },
                                  child: const Text(
                                    "Back",
                                    style: TextStyle(
                                      color: Color(0xFF4F4F4F),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF070B19),
                                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: (idController.text.isNotEmpty &&
                                          pickedFileName != null)
                                      ? () {
                                          Navigator.pop(context);
                                        }
                                      : null,
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- DRIVER VERIFICATION DIALOG ---
  static void showDriverVerification(BuildContext context) {
    TextEditingController drivingLicenseController = TextEditingController();
    TextEditingController nidController = TextEditingController();
    TextEditingController vehicleRegController = TextEditingController();

    int currentPage = 1; 

    String? pickedLicenseFile;
    String? pickedNidFile;
    String? pickedVehicleRegFile;
    String? pickedInsuranceFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool isFormValid = drivingLicenseController.text.isNotEmpty &&
                nidController.text.isNotEmpty &&
                vehicleRegController.text.isNotEmpty;

            bool isAllUploaded = pickedLicenseFile != null &&
                pickedNidFile != null &&
                pickedVehicleRegFile != null &&
                pickedInsuranceFile != null;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.close,
                          color: Color(0xFF4F4F4F),
                          size: 24,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F8FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: Color(0xFF2F80ED),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Driver Verification",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentPage == 3
                          ? "Upload Documents"
                          : "Complete verification to start posting rides",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF828282)),
                    ),
                    const SizedBox(height: 24),

                    if (currentPage == 1) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              currentPage = 2;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF070B19),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Start Verification",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ] else if (currentPage == 2) ...[
                      _buildFieldLabel("Driving License Number *"),
                      TextField(
                        controller: drivingLicenseController,
                        onChanged: (_) => setModalState(() {}),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        decoration: _buildVideoInputDecoration("e.g., DHA-123456789"),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel("NID Number *"),
                      TextField(
                        controller: nidController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setModalState(() {}),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        decoration: _buildVideoInputDecoration("e.g., 1234567890"),
                      ),
                      const SizedBox(height: 16),
                      _buildFieldLabel("Vehicle Registration Number *"),
                      TextField(
                        controller: vehicleRegController,
                        onChanged: (_) => setModalState(() {}),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                        decoration: _buildVideoInputDecoration("e.g., DHA-Metro-11-1234"),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    currentPage = 1;
                                  });
                                },
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Color(0xFF4F4F4F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFormValid
                                      ? const Color(0xFF070B19)
                                      : const Color(0xFFBDBDBD),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isFormValid
                                    ? () {
                                        setModalState(() {
                                          currentPage = 3;
                                        });
                                      }
                                    : null,
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else if (currentPage == 3) ...[
                      _buildVideoStyleUploadCard(
                        title: "Driving License",
                        subtitle: "Clear photo of both sides",
                        icon: Icons.credit_card_rounded,
                        pickedFile: pickedLicenseFile,
                        onTap: () async {
                          FilePickerResult? r = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                          );
                          if (r != null) {
                            setModalState(() => pickedLicenseFile = r.files.single.name);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildVideoStyleUploadCard(
                        title: "National ID Card",
                        subtitle: "Front and back side",
                        icon: Icons.assignment_ind_outlined,
                        pickedFile: pickedNidFile,
                        onTap: () async {
                          FilePickerResult? r = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                          );
                          if (r != null) {
                            setModalState(() => pickedNidFile = r.files.single.name);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildVideoStyleUploadCard(
                        title: "Vehicle Registration",
                        subtitle: "BRTA registration certificate",
                        icon: Icons.directions_car_filled_outlined,
                        pickedFile: pickedVehicleRegFile,
                        onTap: () async {
                          FilePickerResult? r = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                          );
                          if (r != null) {
                            setModalState(() => pickedVehicleRegFile = r.files.single.name);
                          }
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildVideoStyleUploadCard(
                        title: "Vehicle Insurance",
                        subtitle: "Valid insurance certificate",
                        icon: Icons.shield_outlined,
                        pickedFile: pickedInsuranceFile,
                        onTap: () async {
                          FilePickerResult? r = await FilePicker.platform.pickFiles(
                            type: FileType.custom,
                            allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                          );
                          if (r != null) {
                            setModalState(() => pickedInsuranceFile = r.files.single.name);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    currentPage = 2;
                                  });
                                },
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Color(0xFF4F4F4F),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAllUploaded
                                      ? const Color(0xFF070B19)
                                      : const Color(0xFF9EA8B3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: isAllUploaded
                                    ? () {
                                        Navigator.pop(context);
                                      }
                                    : null,
                                child: const Text(
                                  'Submit for Verification',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ========================================================
  // --- PRIVATE COMPONENTS & CARD BUILDERS (VIDEO STYLE) ---
  // ========================================================
  static Widget _buildVideoStyleUploadCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String? pickedFile,
    required VoidCallback onTap,
  }) {
    bool isUploaded = pickedFile != null;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEAEFF5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2F80ED), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8E9AA8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFFFAFCFE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isUploaded ? const Color(0xFF219653) : const Color(0xFFD3DFEE),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUploaded ? Icons.check_circle_rounded : Icons.file_upload_outlined,
                    color: isUploaded ? const Color(0xFF219653) : const Color(0xFF8E9AA8),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      isUploaded ? pickedFile! : "Click to upload",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isUploaded ? const Color(0xFF219653) : const Color(0xFF5F6E7D),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Text(
            '✓ ',
            style: TextStyle(
              color: Color(0xFF2F80ED),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2F80ED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 2),
        child: Row(
          children: [
            Text(
              label.replaceAll(" *", ""),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            if (label.contains("*"))
              const Text(
                " *",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Updated to match exactly like the screenshot with Emojis
  static Widget _buildRoleDropdown({
    required String? value,
    required String hint,
    required Function(String?) onChanged,
  }) {
    final Map<String, String> roleConfig = {
      'Student': '🎓',
      'Faculty Member': '👨‍🏫',
      'Staff Member': '💼',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      height: 48,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFBDBDBD),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF828282),
          ),
          items: roleConfig.keys.map((String role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Row(
                children: [
                  Text(
                    roleConfig[role]!,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    role,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF333333),
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

  // Updated to match exact search-style layout with trailing search icon
  static Widget _buildBottomSheetSelector({
    required String hint,
    required String value,
    required VoidCallback onTap,
  }) {
    bool hasValue = value.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1.0,
          ),
        ),
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                hasValue ? value : hint,
                style: TextStyle(
                  fontSize: 13,
                  color: hasValue ? const Color(0xFF333333) : const Color(0xFFBDBDBD),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.search_rounded,
              color: Color(0xFFBDBDBD),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  static InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFBDBDBD),
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF2F2F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2F80ED)),
      ),
    );
  }

  static InputDecoration _buildVideoInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD3DFEE), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 1.5),
      ),
    );
  }

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
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setSheetState(() {
                          filteredItems = allItems
                              .where((item) => item
                                  .toLowerCase()
                                  .contains(val.toLowerCase()))
                              .toList();
                        });
                      },
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF828282),
                          size: 22,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2).withOpacity(0.5),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
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