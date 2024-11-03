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
      zoom: 18,
      target: LatLng(29.978992404450963, 31.25088978734445),
    );
    super.initState();
  }

  late GoogleMapController googleMapController;
  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        onMapCreated: (controller) {
          googleMapController = controller;
        },
        initialCameraPosition: initialCameraPosition,
        // cameraTargetBounds: CameraTargetBounds(
        //   LatLngBounds(
        //     southwest: const LatLng(29.977119405274014, 31.249217375163916),
        //     northeast: const LatLng(29.98138624646672, 31.256507255830215),
        //   ),
        // ),
      ),
      Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ElevatedButton(
              onPressed: () {
                initialCameraPosition = const CameraPosition(
                  zoom: 18,
                  target: LatLng(29.978992404450963, 31.25088978734445),
                );
                setState(() {});
              },
              child: const Text('Change Location')))
    ]);
  }
}