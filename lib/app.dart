import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:para_client/app_view.dart';
import 'package:para_client/core/services/location_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeLocationService(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: Text('Error initializing location service'),
                  ),
                ),
              );
            }
            return const AppView();
          }
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(),
              ),
            ),
          );
        });
  }

  Future<void> _initializeLocationService() async {
    final locationService = LocationService();
    bool hasPermission =
        await locationService.checkAndRequestLocationPermissions();
    if (!hasPermission) {
      throw Exception(
          'Location permission not granted or location service disabled');
    }
  }
}
