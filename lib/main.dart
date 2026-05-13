import 'package:flutter/material.dart';
// Apnar folder structure onujayi import path:
import 'package:rideshare/profile_update/profileupdate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RideShare App',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      // Apnar profileupdate.dart file-e class-er nam "ProfileScreen"
      home: const ProfileScreen(), 
    );
  }
}