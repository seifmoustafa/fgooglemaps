import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:fgooglemaps/models/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatefulWidget {
  const CustomGoogleMap({super.key});

  @override
  State<CustomGoogleMap> createState() => _CustomGoogleMapState();
}

/// CustomGoogleMap is a widget that displays a Google Map with custom markers,
/// polylines, and polygons. It allows the user to change the map's location
/// through a button.
class _CustomGoogleMapState extends State<CustomGoogleMap> {
  /// The initial camera position of the Google Map.
  late CameraPosition initialCameraPosition;
  late Location location;
  @override
  void initState() {
    // Set the initial camera position with a specific zoom level and target coordinates.
    initialCameraPosition = const CameraPosition(
      zoom: 18,
      target: LatLng(29.978992404450963, 31.25088978734445),
    );
    initPolyLines();
    initMarkers();
    initPolygons();
    initCircles();
    updateMyLocation();
    location = Location();

    super.initState();
  }

  /// The controller for managing the Google Map.
  GoogleMapController? googleMapController;

  @override
  void dispose() {
    // Dispose of the Google Map controller when the widget is removed from the widget tree.
    googleMapController!.dispose();
    super.dispose();
  }

  /// A set of circles to be drawn on the map.

  Set<Circle> circles = {};

  /// A set of polylines to be drawn on the map.
  Set<Polyline> polyLines = {};

  /// A set of polygons to be drawn on the map.
  Set<Polygon> polygons = {};

  /// A set of markers to be displayed on the map.
  Set<Marker> markers = {};

  /// The style of the map, which can be customized.
  String? mapStyle;

  @override
  Widget build(BuildContext context) {
    // Build the Google Map widget with specified properties.
    return Stack(children: [
      GoogleMap(
        circles: circles,
        polygons: polygons,
        polylines: polyLines,
        markers: markers,
        style: mapStyle,
        zoomControlsEnabled: false,
        onMapCreated: (controller) {
          // Initialize the Google Map controller and set the map style.
          googleMapController = controller;
          initMapStyle();
        },
        initialCameraPosition: initialCameraPosition,
      ),
      Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: ElevatedButton(
              onPressed: () {
                // Animate the camera to a new location when the button is pressed.
                googleMapController!.animateCamera(CameraUpdate.newLatLng(
                    const LatLng(29.981408053771613, 31.25643925103204)));
                setState(() {});
              },
              child: const Text('Change Location')))
    ]);
  }

  /// Initializes the map style by loading it from an asset file.
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

  /// Initializes and adds a polygon to the collection of polygons.
  ///
  /// This function creates a new instance of a `Polygon` with specified properties,
  /// including its vertices (points), holes, stroke width, fill color, and a unique
  /// identifier. The polygon is then added to the `polygons` collection for rendering
  /// on a map.
  ///
  /// The polygon represents a specific geographical area defined by its vertices,
  /// and it includes a hole that represents an area that is not part of the polygon.
  ///
  /// The vertices and holes are defined using latitude and longitude coordinates
  /// (LatLng objects). The fill color is set to a semi-transparent black, and the
  /// stroke width is set to 3 pixels.
  ///
  /// Example usage:
  /// ```dart
  /// initPolygons();
  /// ```
  ///
  /// Note: Ensure that the `polygons` collection is initialized before calling this
  /// function.
  ///
  /// See also:
  /// - [Polygon] for more details on polygon properties.
  /// - [LatLng] for information on latitude and longitude representation.
  void initPolygons() {
    Polygon polygon = Polygon(
      holes: const [
        [
          LatLng(29.97904848522165, 31.251212787795257),
          LatLng(29.9787832416292, 31.25133239995366),
          LatLng(29.97880120293013, 31.250546140019658),
          LatLng(29.979225314992917, 31.25039941320513),
        ]
      ],
      strokeWidth: 3,
      fillColor: Colors.black.withOpacity(.5),
      polygonId: const PolygonId('1'),
      points: const [
        LatLng(29.978534571809206, 31.252236681286924),
        LatLng(29.97987460492306, 31.251560468916004),
        LatLng(29.979305438872892, 31.249818886915723),
        LatLng(29.978447544019765, 31.249956047749247),
      ],
    );
    polygons.add(polygon);
  }

  /// Initializes and adds a circle to the map.
  ///
  /// This function creates a `Circle` object with specified properties such as
  /// fill color, stroke color, radius, stroke width, and center location.
  /// The circle is then added to the `circles` collection for rendering on the map.
  ///
  /// The circle is configured with the following parameters:
  /// - **Fill Color**: A semi-transparent red color (opacity of 0.5).
  /// - **Stroke Color**: Black color for the circle's border.
  /// - **Radius**: 200 units (the unit depends on the map's coordinate system).
  /// - **Stroke Width**: 5 units for the border thickness.
  /// - **Center**: Latitude and longitude of the circle's center (29.978576678313352, 31.248548124056367).
  /// - **Circle ID**: A unique identifier for the circle ('1').
  void initCircles() {
    Circle bestCircle = Circle(
      fillColor: Colors.red.withOpacity(.5),
      strokeColor: Colors.black,
      radius: 200,
      strokeWidth: 5,
      center: const LatLng(29.978576678313352, 31.248548124056367),
      circleId: const CircleId('1'),
    );
    circles.add(bestCircle);
  }

  Future<void> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        const ScaffoldMessenger(
          child: SnackBar(
            content: Text('We need the permission bro!'),
          ),
        );
      }
    }
  }

  Future<bool> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        const ScaffoldMessenger(
          child: SnackBar(
            content: Text('We need the permission bro!'),
          ),
        );
        return false;
      }
    } else {
      return true;
    }
    return true;
  }

  void getlocationData() {
    location.onLocationChanged.listen((locationData) {
      var cameraPosition = CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!));
      googleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  void updateMyLocation() async {
    await checkAndRequestLocationService();
    var hasPermission = await checkAndRequestLocationPermission();
    if (hasPermission) {
      getlocationData();
    }
  }
}
