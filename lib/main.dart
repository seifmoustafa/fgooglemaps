import 'package:flutter/material.dart';
import 'package:fgooglemaps/widgets/custom_google_map.dart';

void main() {
  runApp(const FWithGoogleMaps());
}

class FWithGoogleMaps extends StatelessWidget {
  const FWithGoogleMaps({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomGoogleMap(),
    );
  }
}
