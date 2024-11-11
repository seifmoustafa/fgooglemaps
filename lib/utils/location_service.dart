import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  /// Checks if the location service is enabled on the device.
  /// If the service is not enabled, it requests the user to enable it.
  /// Displays a SnackBar if the permission is denied.
  ///
  /// This method is asynchronous and returns a [Future<void>].
  Future<bool> checkAndRequestLocationService() async {
    var isServiceEnabled = await location.serviceEnabled();
    if (!isServiceEnabled) {
      isServiceEnabled = await location.requestService();
      if (!isServiceEnabled) {
        return false;
      }
    }
    return true;
  }

  /// Checks if the location permission is granted.
  /// If permission is denied, it requests the user for permission.
  /// Returns false if permission is denied forever or if the user does not grant permission.
  /// Returns true if permission is already granted or granted after the request.
  ///
  /// This method is asynchronous and returns a [Future<bool>].
  Future<bool> checkAndRequestLocationPermission() async {
    var permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.deniedForever) {
      return false;
    }
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      return permissionStatus == PermissionStatus.granted;
    }
    return true;
  }

  void getRealTimeLocationData(void Function(LocationData)? onData) {
    location.onLocationChanged.listen(onData);
  }
}
