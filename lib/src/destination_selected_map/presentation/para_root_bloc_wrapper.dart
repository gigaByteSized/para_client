import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/features/injection_container.dart';
import 'package:para_client/core/services/itinerary_helpers.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_bloc.dart';
import 'package:para_client/src/destination_selected_map/presentation/para_root.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';

// ignore: must_be_immutable
class ParaRootBlocWrapper extends StatelessWidget {
  ParaRootBlocWrapper(
      {super.key,
      this.origin,
      this.destination,
      this.feature,
      this.fareClass,
      this.time});

  LatLng? origin;
  LatLng? destination;
  final Feature? feature;
  FareClasses? fareClass;
  TimeOfDay? time;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteReverseBloc>(
        create: (context) => sl<RemoteReverseBloc>(),
        child: ParaRoot(
            origin: origin,
            destination: destination,
            feature: feature,
            fareClass: fareClass,
            time: time));
  }
}
