import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:gps2/location_screen.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS Proje',
      home: const LocationScreen(), // const eklenmiş hali
    );
  }
}