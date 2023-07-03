import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSample2 extends StatefulWidget {
  const MapSample2({super.key});

  @override
  State<MapSample2> createState() => _MapSample2State();
}

class _MapSample2State extends State<MapSample2> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(35.6861789, 139.8041426);

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map Sample')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
      ),
    );
  }
}
