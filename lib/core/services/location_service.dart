import 'package:geolocator/geolocator.dart';

export 'location_service.dart';

class LocationService {
  Future<bool> checkAndRequestLocationPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, do not continue accessing the position
      // and request users of the App to enable the location services.
      await Geolocator.openLocationSettings();
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      await Geolocator.openAppSettings();
      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }
}

// Return current location
Future<Position> getCurrentLocation() async {
  return await Geolocator.getCurrentPosition();
}

// Return last known location
Future<Position?> getLastKnownLocation() async {
  return await Geolocator.getLastKnownPosition();
}
