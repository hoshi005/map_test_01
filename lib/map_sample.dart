import 'dart:async';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

enum LocationSettingResult {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  enabled,
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  // 初期位置.
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.6861789, 139.8041426),
    zoom: 14.4746,
  );

  // 移動先.
  static const CameraPosition _kLake = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(35.4984714, 138.8295337),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414,
  );

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: GoogleMap(
    //     mapType: MapType.hybrid,
    //     initialCameraPosition: _kGooglePlex,
    //     onMapCreated: (GoogleMapController controller) {
    //       _controller.complete(controller);
    //     },
    //   ),
    //   floatingActionButton: FloatingActionButton.extended(
    //     onPressed: _goToTheLake,
    //     label: const Text('To the lake!'),
    //     icon: const Icon(Icons.directions_boat),
    //   ),
    // );

    return FutureBuilder(
      future: _initAsync(context),
      builder: ((context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: snapshot.data ?? LatLng(35.6861789, 139.8041426),
            zoom: 14.4746,
          ),
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        );
      }),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  /// 位置情報に関するパーミッションの確認.
  Future<LocationSettingResult> checkLocationSetting() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print('=== Location services are disabled.');
      return Future.value(LocationSettingResult.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('=== Location permissions are denied');
        return Future.value(LocationSettingResult.permissionDenied);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print(
          '=== Location permissions are permanently denied, we cannot request permissions.');
      return Future.value(LocationSettingResult.permissionDeniedForever);
    }

    return Future.value(LocationSettingResult.enabled);
  }

  Future<void> recoverLocationSettings(
      BuildContext context, LocationSettingResult locationSettingResult) async {
    if (locationSettingResult == LocationSettingResult.enabled) {
      return;
    }

    final result = await showOkCancelAlertDialog(
      context: context,
      okLabel: 'OK',
      cancelLabel: 'CANCEL',
      title: 'TITLE',
      message: 'MESSAGE',
    );

    if (result == OkCancelResult.cancel) {
      print('Cancel recover location settings.');
    } else {
      locationSettingResult == LocationSettingResult.serviceDisabled
          ? Geolocator.openLocationSettings()
          : Geolocator.openAppSettings();
    }
  }

  Future<LatLng> _initAsync(BuildContext context) async {
    final result = await checkLocationSetting();
    if (result != LocationSettingResult.enabled) {
      await recoverLocationSettings(context, result);
    }
    return await getCurrentLocation();
  }

  Future<LatLng> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
}
