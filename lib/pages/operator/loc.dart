import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Live Location Tracker',
      home: LocationStreamPage(),
    );
  }
}

// --- LocationStreamPage Widget ---

class LocationStreamPage extends StatefulWidget {
  const LocationStreamPage({super.key});

  @override
  State<LocationStreamPage> createState() => _LocationStreamPageState();
}

class _LocationStreamPageState extends State<LocationStreamPage> {
  // Store the current position data
  Position? _currentPosition;
  // Store any errors that occur
  String _error = '';
  // Stream subscription to manage updates
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _startLocationStream();
  }

  @override
  void dispose() {
    // IMPORTANT: Cancel the subscription when the widget is disposed
    // to prevent memory leaks and unnecessary battery usage.
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // --- Core Location Logic ---

  Future<void> _startLocationStream() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _error = 'Location services are disabled. Please enable them.';
      });
      return;
    }

    // 2. Check and request location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions denied.';
        });
        return;
      }
    }

    // 3. Permissions granted, set up the stream
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, // Use high accuracy
      distanceFilter: 5, // Update only when position changes by 5 meters
    );

    // Get the stream and subscribe to it
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            // Automatically called whenever a new position is available
            setState(() {
              _currentPosition = position;
              _error = ''; // Clear any previous errors
            });
          },
          onError: (e) {
            // Handle stream errors (e.g., GPS signal lost)
            setState(() {
              _error = 'Error receiving location update: $e';
            });
          },
          cancelOnError: true,
        );
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Stream'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(Icons.location_on, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              if (_error.isNotEmpty)
                _buildErrorText()
              else if (_currentPosition == null)
                _buildLoadingState()
              else
                _buildLocationData(),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _startLocationStream,
                child: const Text('Restart Location Tracking'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 10),
        Text('Awaiting location data...', style: TextStyle(fontSize: 18)),
        Text('Please ensure permissions and GPS are enabled.'),
      ],
    );
  }

  Widget _buildErrorText() {
    return Text(
      'LOCATION ERROR: $_error',
      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLocationData() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Live Coordinates:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Latitude: **${_currentPosition!.latitude.toStringAsFixed(6)}**',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              'Longitude: **${_currentPosition!.longitude.toStringAsFixed(6)}**',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text(
              'Altitude: ${_currentPosition!.altitude.toStringAsFixed(2)} m',
            ),
            Text(
              'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(2)} m',
            ),
          ],
        ),
      ),
    );
  }
}
