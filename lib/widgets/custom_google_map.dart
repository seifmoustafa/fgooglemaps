import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fgooglemaps/models/place_model.dart';
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
    initMarkers();
    super.initState();
  }

  late GoogleMapController googleMapController;
  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  Set<Marker> markers = {};
  String? mapStyle;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        markers: markers,
        style: mapStyle,
        // mapType: MapTy pe.hybrid,
        zoomControlsEnabled: true,
        onMapCreated: (controller) {
          googleMapController = controller;
          initMapStyle();
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
                googleMapController.animateCamera(CameraUpdate.newLatLng(
                    const LatLng(29.981408053771613, 31.25643925103204)));
                setState(() {});
              },
              child: const Text('Change Location')))
    ]);
  }

  Future initMapStyle() async {
    mapStyle = await DefaultAssetBundle.of(context)
        .loadString("assets/map_styles/night_map_style.json");
    setState(() {});
  }

  /// Asynchronously loads an image from raw data, resizes it to the specified width,
  /// and returns the image as a Uint8List in PNG format.
  ///
  /// [image] is the path to the image asset in the app's bundle.
  /// [width] is the desired width to which the image will be resized.
  ///
  /// Returns a [Future<Uint8List>] containing the image data in PNG format.
  Future<Uint8List> getImageFromRawData(String image, double width) async {
    // Load the image data from the asset bundle.
    var imageData = await rootBundle.load(image);

    // Instantiate an image codec for the loaded image data, resizing it to the target width.
    var imageCodec = await ui.instantiateImageCodec(
        imageData.buffer.asUint8List(),
        targetWidth: width.round());

    // Retrieve the first frame of the image.
    imageCodec.getNextFrame();

    // Get the next frame of the image, which contains the actual image data.
    var imageFrame = await imageCodec.getNextFrame();

    // Convert the image frame to byte data in PNG format.
    var imageBytes =
        await imageFrame.image.toByteData(format: ui.ImageByteFormat.png);

    // Return the image bytes as a Uint8List.
    return imageBytes!.buffer.asUint8List();
  }

  void initMarkers() async {
    var customMarkerIcon = await BitmapDescriptor.bytes(
        await getImageFromRawData('assets/images/marker.png', 50));
    var myMarkers = places
        .map(
          (placeModel) => Marker(
            icon: customMarkerIcon,
            infoWindow: InfoWindow(
              title: placeModel.name,
            ),
            position: placeModel.latLng,
            markerId: MarkerId(
              placeModel.id.toString(),
            ),
          ),
        )
        .toSet();
    markers.addAll(myMarkers);
    setState(() {});
  }
}
