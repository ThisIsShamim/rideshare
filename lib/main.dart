import 'package:flutter/material.dart';
// আপনার profile.dart ফাইলটি ইম্পোর্ট করুন
import 'profile/profile.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Share App',
      debugShowCheckedModeBanner: false, // ডানদিকের উপরের Debug ব্যানার সরাতে
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // এখানে home হিসেবে ProfileScreen কে কল করে দিন
      home: const ProfileScreen(), 
    );
  }
}