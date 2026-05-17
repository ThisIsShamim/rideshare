import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceCalculatorService {
  // আপনার OpenWeatherMap API Key এখানে দিন
  static const String _weatherApiKey = "951ed353260056e33fbdcbac109121e7";

  static Future<int> calculateSmartPrice({
    required double distanceKm,
    required double durationMins,
    required double pickupLat,
    required double pickupLng,
  }) async {
    // ১. Base Price Calculation (বেসিক ভাড়া)
    double baseFare = 40.0; // ওঠার ভাড়া
    double perKmRate = 15.0; // প্রতি কি.মি. ভাড়া
    double perMinRate = 2.0; // প্রতি মিনিট ভাড়া

    double normalPrice =
        baseFare + (distanceKm * perKmRate) + (durationMins * perMinRate);

    // ২. Time Multiplier (সময় অনুযায়ী সার্জ)
    double timeMultiplier = _getTimeMultiplier();

    // ৩. Weather Multiplier (আবহাওয়া অনুযায়ী সার্জ)
    double weatherMultiplier = await _getWeatherMultiplier(
      pickupLat,
      pickupLng,
    );

    // ৪. Final Price Calculation
    double finalPrice = normalPrice * timeMultiplier * weatherMultiplier;

    // রাউন্ডিং করে ১০ এর গুণিতক করা (যেমন ১৩২ টাকা হলে ১৩০ বা ১৪০ করবে)
    return (finalPrice / 10).round() * 10;
  }

  // সময় অনুযায়ী প্রাইস মাল্টিপ্লায়ার
  static double _getTimeMultiplier() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    // Morning Rush Hour (8 AM - 10 AM)
    if (hour >= 8 && hour <= 10) return 1.3;

    // Evening Rush Hour (5 PM - 8 PM)
    if (hour >= 17 && hour <= 20) return 1.5;

    // Late Night (11 PM - 5 AM)
    if (hour >= 23 || hour <= 5) return 1.2;

    // Normal Time
    return 1.0;
  }

  // আবহাওয়া অনুযায়ী প্রাইস মাল্টিপ্লায়ার (API Call)
  static Future<double> _getWeatherMultiplier(double lat, double lng) async {
    try {
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=$_weatherApiKey';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String mainWeather = data['weather'][0]['main']
            .toString()
            .toLowerCase();

        // যদি বৃষ্টি, বজ্রপাত বা তুষারপাত হয়, তাহলে ভাড়া বাড়বে
        if (mainWeather.contains('rain') || mainWeather.contains('drizzle')) {
          return 1.4; // ৪০% ভাড়া বেশি বৃষ্টির কারণে
        } else if (mainWeather.contains('thunderstorm') ||
            mainWeather.contains('snow')) {
          return 1.6; // ৬০% ভাড়া বেশি
        } else if (mainWeather.contains('clouds')) {
          return 1.1; // মেঘলা হলে সামান্য বেশি (ঐচ্ছিক)
        }
      }
    } catch (e) {
      print("Weather API Error: $e");
    }

    // আবহাওয়া স্বাভাবিক হলে বা API ফেইল করলে নরমাল প্রাইস
    return 1.0;
  }
}
