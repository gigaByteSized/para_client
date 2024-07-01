import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/features/injection_container.dart';
import 'package:para_client/src/search/presentation/bloc/feature/remote/remote_feature_bloc.dart';
import 'package:para_client/src/search/presentation/search_screen.dart';

class SearchBlocWrapper extends StatelessWidget {
  const SearchBlocWrapper(
      {super.key, this.mode, this.initialQuery, this.initialCenter});

  final String? mode;
  final String? initialQuery;
  final LatLng? initialCenter;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RemoteFeatureBloc>(
        create: (context) => sl<RemoteFeatureBloc>(),
        child: SearchScreen(
          mode: mode,
          initialQuery: initialQuery,
          initialCenter: initialCenter,
        ));
  }
}
