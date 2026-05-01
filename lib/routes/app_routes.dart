import 'package:flutter/material.dart';

import '../presentation/find_a_ride_screen/find_a_ride_screen.dart';
import '../presentation/post_a_ride_screen/post_a_ride_screen.dart';
import '../presentation/ride_detail_screen/ride_detail_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/sign_up_screen/sign_up_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String signUpScreen = '/sign-up-screen';
  static const String findARideScreen = '/find-a-ride-screen';
  static const String rideDetailScreen = '/ride-detail-screen';
  static const String postARideScreen = '/post-a-ride-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LoginScreen(),
    loginScreen: (context) => const LoginScreen(),
    signUpScreen: (context) => const SignUpScreen(),
    findARideScreen: (context) => const FindARideScreen(),
    rideDetailScreen: (context) => const RideDetailScreen(),
    postARideScreen: (context) => const PostARideScreen(),
  };
}
