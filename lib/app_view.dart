import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/itinerary_helpers.dart';
import 'package:para_client/core/shared/theme_provider.dart';
import 'package:para_client/src/alerts_module/add_alert.dart';
import 'package:para_client/src/alerts_module/alerts_page.dart';
import 'package:para_client/src/destination_selected_map/presentation/para_root_bloc_wrapper.dart';
import 'package:para_client/src/plan_trip/plan_trip_bloc_wrapper.dart';
import 'package:para_client/src/route_feedback_module/route_feedback.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';
import 'package:para_client/src/route_selector/presentation/route_root.dart';
import 'package:para_client/src/search/presentation/search_bloc_wrapper.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PARA!: Public transit Automated Routing Assistant',
      theme: ThemeProvider().themeData, // Integrate theme_provider.dart here
      // home: const RouteRoot(title: 'PARA!'),
      initialRoute: '/',
      routes: {
        '/': (context) => const RouteRoot(title: 'PARA!'),
        '/mapView': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          final origin = args['origin'] as LatLng?;
          final destination = args['destination'] as LatLng?;
          final feature = args['feature'] as Feature?;
          final fareClass = args['fareClass'] as FareClasses?;
          final time = args['time'] as TimeOfDay?;
          return ParaRootBlocWrapper(
              origin: origin,
              destination: destination,
              feature: feature,
              fareClass: fareClass,
              time: time);
        },
        '/search': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          final mode = args['mode'] as String?;
          final initialQuery = args['initialQuery'] as String?;
          final initialCenter = args['initialCenter'] as LatLng?;
          return SearchBlocWrapper(
            mode: mode,
            initialQuery: initialQuery,
            initialCenter: initialCenter,
          );
        },
        '/plan': (context) => const PlanTripBlocWrapper(),
        '/add_alert': (context) => const AddAlert(),
        '/alerts_page': (context) => const AlertsPage(),
        '/route_feedback': (context) => const RouteFeedback(),
      },
    );
  }
}
