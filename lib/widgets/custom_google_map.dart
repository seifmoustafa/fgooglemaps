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
    initPolyLines();
    initMarkers();
    super.initState();
  }

  late GoogleMapController googleMapController;
  @override
  void dispose() {
    googleMapController.dispose();
    super.dispose();
  }

  Set<Polyline> polyLines = {};
  Set<Marker> markers = {};
  String? mapStyle;
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      GoogleMap(
        polylines: polyLines,
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

  /// Initializes and adds custom markers to the map.
  ///
  /// This method retrieves a custom marker icon from the specified asset
  /// and creates a set of markers based on the provided `places` list.
  /// Each marker is associated with a specific place, identified by its
  /// unique ID, and includes an info window that displays the place's name.
  ///
  /// The method performs the following steps:
  /// 1. Loads a custom marker icon from the assets.
  /// 2. Maps over the `places` list to create a set of markers.
  /// 3. Each marker is created with the following properties:
  ///    - `icon`: The custom marker icon.
  ///    - `infoWindow`: An info window containing the title of the place.
  ///    - `position`: The geographical coordinates of the place.
  ///    - `markerId`: A unique identifier for the marker based on the place's ID.
  /// 4. Adds the created markers to the `markers` set.
  /// 5. Calls `setState` to update the UI.
  ///
  /// This method is asynchronous and should be awaited if called from an
  /// async context.
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

  /// Initializes and adds a polyline to the map.
  ///
  /// This method creates a polyline that represents a series of connected
  /// geographical points. The polyline is defined by specific properties,
  /// including its appearance and the coordinates of its points.
  ///
  /// The method performs the following steps:
  /// 1. Creates a new Polyline object with the following properties:
  ///    - `geodesic`: Indicates that the polyline should follow the curvature
  ///      of the Earth.
  ///    - `width`: Sets the width of the polyline in pixels.
  ///    - `startCap`: Defines the style of the starting cap of the polyline,
  ///      in this case, a rounded cap.
  ///    - `color`: Specifies the color of the polyline, which is red in this
  ///      instance.
  ///    - `polylineId`: Assigns a unique identifier for the polyline ('1').
  ///    - `points`: A list of geographical coordinates (LatLng) that define
  ///      the shape of the polyline.
  /// 2. Adds the created polyline to the existing collection of polylines
  ///    (polyLines).
  void initPolyLines() {
    // Create a new Polyline object with the specified properties.
    Polyline polyline = const Polyline(
      geodesic:
          true, // Indicates that the polyline follows the curvature of the Earth.
      width: 5, // The width of the polyline in pixels.
      startCap: Cap.roundCap, // The style of the starting cap of the polyline.
      color: Colors.red, // The color of the polyline.
      polylineId: PolylineId('1'), // Unique identifier for the polyline.

      // List of geographical points (LatLng) that define the shape of the polyline.
      points: [
        LatLng(29.978893629559657, 31.25116592286826), // First point
        LatLng(29.979215990242274, 31.250854668366852), // Second point
        LatLng(29.978682628650144, 31.251637313264673), // Third point
        LatLng(29.97801837046042, 31.251057661114288), // Fourth point
        LatLng(29.97926873389208, 31.249720164501063), // Fifth point
      ],
    );

    // Add the created polyline to the collection of polylines.
    polyLines.add(polyline);
  }
}
