import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class VerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // TODO: Ekhane apnar Cloudinary er details boshan
  final String cloudName = "dapqiusuf"; // Dashboard theke paben
  final String uploadPreset =
      "pkhzfhet"; // Jemonti baniyechen (e.g., rideshare_preset)

  // --- Cloudinary te File Upload korar function ---
  Future<String?> uploadFile(PlatformFile file) async {
    try {
      // Cloudinary API URL (image, pdf sobkichur jonnoi 'auto' use kora valo)
      var uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/auto/upload",
      );
      var request = http.MultipartRequest("POST", uri);

      // Web ba Mobile er jonno file add kora
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      // Preset add kora
      request.fields['upload_preset'] = uploadPreset;

      // Upload request pathano
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonMap = jsonDecode(responseData);
        return jsonMap['secure_url']; // Ei URL ta amader lagbe
      } else {
        print("Cloudinary Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error uploading file to Cloudinary: $e");
      return null;
    }
  }

  // --- User Verification save korar function ---
  Future<bool> submitUserVerification({
    required String role,
    required String university,
    required String department,
    required String idNumber,
    required PlatformFile profilePhoto,
    required PlatformFile idCardFile,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      // ১. Cloudinary te File Upload
      String? profilePhotoUrl = await uploadFile(profilePhoto);
      String? idCardUrl = await uploadFile(idCardFile);

      if (profilePhotoUrl == null || idCardUrl == null) return false;

      // ২. Firestore e URL gulo save kora
      await _firestore.collection('user_verifications').doc(user.uid).set({
        'uid': user.uid,
        'role': role,
        'university': university,
        'department': department,
        'idNumber': idNumber,
        'profilePhotoUrl': profilePhotoUrl,
        'idCardUrl': idCardUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Error saving user verification: $e");
      return false;
    }
  }

  // --- Driver Verification save korar function ---
  Future<bool> submitDriverVerification({
    required String drivingLicenseNumber,
    required String nidNumber,
    required String vehicleRegNumber,
    required PlatformFile licenseFile,
    required PlatformFile nidFile,
    required PlatformFile vehicleRegFile,
    required PlatformFile insuranceFile,
  }) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      // ১. Cloudinary te File Upload
      String? licenseUrl = await uploadFile(licenseFile);
      String? nidUrl = await uploadFile(nidFile);
      String? vehicleRegUrl = await uploadFile(vehicleRegFile);
      String? insuranceUrl = await uploadFile(insuranceFile);

      if (licenseUrl == null ||
          nidUrl == null ||
          vehicleRegUrl == null ||
          insuranceUrl == null) {
        return false;
      }

      // ২. Firestore e URL gulo save kora
      await _firestore.collection('driver_verifications').doc(user.uid).set({
        'uid': user.uid,
        'drivingLicenseNumber': drivingLicenseNumber,
        'nidNumber': nidNumber,
        'vehicleRegNumber': vehicleRegNumber,
        'licenseUrl': licenseUrl,
        'nidUrl': nidUrl,
        'vehicleRegUrl': vehicleRegUrl,
        'insuranceUrl': insuranceUrl,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      print("Error saving driver verification: $e");
      return false;
    }
  }
}
