import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:latlong2/latlong.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final MapController _mapController = MapController();

  StreamSubscription<Position>? _posSub;
  LatLng? _currentLatLng;
  bool _firstFixDone = false;

  static const blue = Color(0xFF0D4896);

  @override
  void initState() {
    super.initState();
    _startLocationStream();
  }

  Future<void> _startLocationStream() async {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _posSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      final latLng = LatLng(pos.latitude, pos.longitude);

      setState(() {
        _currentLatLng = latLng;
      });

      if (!_firstFixDone) {
        _firstFixDone = true;
        _recenter();
      }
    });
  }

  void _recenter() {
    final p = _currentLatLng;
    if (p == null) return;
    final currentZoom = _mapController.camera.zoom;
    final zoom = currentZoom == 0 ? 16.5 : currentZoom;

    _mapController.move(p, zoom);
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _currentLatLng ?? const LatLng(-1.9441, 30.0619); // Kigali fallback

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16.5,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // important for modern flutter_map / OSM usage
                userAgentPackageName: 'com.example.bus_app',
              ),

              if (_currentLatLng != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLatLng!,
                      width: 50,
                      height: 50,
                      child: const _DriverBusMarker(),
                    ),
                  ],
                ),
            ],
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12, right: 12),
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: _recenter,
                    icon: const Icon(
                      IconsaxPlusLinear.gps,
                      color: blue,
                    ),
                    tooltip: "Recenter",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverBusMarker extends StatelessWidget {
  const _DriverBusMarker();

  static const blue = Color(0xFF0D4896);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: blue.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          IconsaxPlusBold.bus,
          color: blue,
          size: 28,
        ),
      ),
    );
  }
}