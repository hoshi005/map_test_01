import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'locations.dart' as locations;

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(35.6861789, 139.8041426);

  final Map<String, Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    final googleOffices = await locations.getGoogleOffices();
    setState(() {
      _markers.clear();
      for (final office in googleOffices?.offices ?? []) {
        final marker = Marker(
          markerId: MarkerId(office.name),
          position: LatLng(office.lat, office.lng),
          infoWindow: InfoWindow(
            title: office.name,
            snippet: office.address,
          ),
        );
        _markers[office.name] = marker;
      }
    });
  }

  @override
  void initState() {
    super.initState();

    Future(() async {
      await _requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dotenvText = dotenv.env['VAR_NAME'];
    final flutterConfigText = FlutterConfig.get('FLUTTER_CONFIG');
    return Scaffold(
      appBar: AppBar(
        title: Text('$dotenvText + $flutterConfigText'),
        actions: [
          IconButton(
            onPressed: _requestPermission,
            icon: const Icon(Icons.location_city),
          ),
        ],
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: _markers.values.toSet(),
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        onLongPress: (latLng) => _addMarker(latLng: latLng),
        onTap: (latLng) => _moveCamera(latLng),
      ),
    );
  }

  /// 位置情報の権限リクエスト.
  Future<void> _requestPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    } else {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('すでに権限を持っているみたいです.'),
        ),
      );
    }
  }

  /// マーカーを追加.
  void _addMarker({
    required LatLng latLng,
    String? title,
    String? snippet,
  }) {
    final marker = Marker(
      markerId: MarkerId('$latLng'),
      position: latLng,
      infoWindow: InfoWindow(
        title: title ?? 'わっしょい',
        snippet: snippet ?? '$latLng',
      ),
    );
    setState(() {
      _markers['$latLng'] = marker;
    });
  }

  /// カメラを移動.
  void _moveCamera(LatLng latLng) {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(latLng),
    );
  }
}
