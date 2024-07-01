import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:para_client/core/features/injection_container.dart';
import 'package:para_client/src/destination_selected_map/presentation/bloc/feature/remote/remote_reverse_bloc.dart';
import 'package:para_client/src/plan_trip/plan_trip.dart';

class PlanTripBlocWrapper extends StatelessWidget {
  const PlanTripBlocWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteReverseBloc>(
        create: (context) => sl<RemoteReverseBloc>(), child: const PlanTrip());
  }
}
