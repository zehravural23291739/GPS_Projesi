import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _konumMetni = "Konum bilgisi alınmadı.";
  bool _isLoading = false;

  Future<void> _konumuAl() async {
    setState(() {
      _isLoading = true;
      _konumMetni = "Konum alınıyor...";
    });

    try {
      // 1. Konum servislerinin açık olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Konum servisleri kapalı. Lütfen açın.');
      }

      // 2. İzin kontrolü
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Konum izni reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Konum izni kalıcı olarak reddedildi. Ayarlardan açın.');
      }

      // 3. Konum bilgisi al (10 saniye timeout ile)
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      // 4. Adres bilgisi al
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _konumMetni = '''
Enlem: ${position.latitude.toStringAsFixed(6)}
Boylam: ${position.longitude.toStringAsFixed(6)}
Adres: ${placemarks.first.street}, ${placemarks.first.locality}
Zaman: ${DateTime.now().toLocal()}''';
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _konumMetni = 'Hata: ${e.toString()}';
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konum Bilgisi")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_konumMetni,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text('Konumu Al'),
                onPressed: _konumuAl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}