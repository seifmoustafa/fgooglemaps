import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

class _CustomGoogleMapState extends State<CustomGoogleMap> {
  late CameraPosition initialCameraPosition;
  @override
  void initState() {
    initialCameraPosition = const CameraPosition(
      zoom: 19,
      target: LatLng(29.978992404450963, 31.25088978734445),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(initialCameraPosition: initialCameraPosition);
  }
}
