import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  final int id;
  final String name;
  final LatLng latLng;

  PlaceModel({
    required this.id,
    required this.name,
    required this.latLng,
  });
}

List<PlaceModel> places = [
  PlaceModel(
      id: 1,
      name: 'كافيه',
      latLng: const LatLng(29.97450983418806, 31.23422953334269)),
  PlaceModel(
      id: 2,
      name: 'مطعم',
      latLng: const LatLng(29.974987178732306, 31.23802323920141)),
  PlaceModel(
      id: 3,
      name: 'مستشفي',
      latLng: const LatLng(29.977082758495513, 31.242111014282152)),
  PlaceModel(
      id: 4, name: 'حمص', latLng: const LatLng(29.981408053771613, 31.25643925103204))
];
