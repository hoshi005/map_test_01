import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample2 extends StatefulWidget {
  const MapSample2({super.key});

  @override
  State<MapSample2> createState() => _MapSample2State();
}

class _MapSample2State extends State<MapSample2> {
  final Completer<GoogleMapController> _controller = Completer();

  final Position _initialPosition = Position(
    latitude: 35.658034,
    longitude: 139.701636,
    timestamp: DateTime.now(),
    altitude: 0,
    accuracy: 0,
    heading: 0,
    floor: null,
    speed: 0,
    speedAccuracy: 0,
  );

  late Position _currentLocation;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _currentLocation = _initialPosition;

    Timer.periodic(const Duration(seconds: 1), (_) {
      _setCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('現在地')),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(
            _initialPosition.latitude,
            _initialPosition.longitude,
          ),
          zoom: 14.4746,
        ),
        onMapCreated: _controller.complete,
        markers: Set<Marker>.of(_markers),
      ),
    );
  }

  Future<void> _setCurrentLocation() async {
    final currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    const decimalPoint = 3;

    if ((_currentLocation.latitude.toStringAsFixed(decimalPoint) !=
            currentPosition.latitude.toStringAsFixed(decimalPoint)) &&
        (_currentLocation.longitude.toStringAsFixed(decimalPoint) !=
            currentPosition.longitude.toStringAsFixed(decimalPoint))) {
      final marker = Marker(
        markerId: const MarkerId('current'),
        position: LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        ),
        infoWindow: const InfoWindow(
          title: '現在地',
        ),
      );

      setState(() {
        _markers.clear();
        _markers.add(marker);
        _currentLocation = currentPosition;
      });
    }
  }
}
