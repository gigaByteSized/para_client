import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:para_client/app.dart';
import 'package:para_client/core/constants/graphQL/graphql_base_queries.dart';
import 'package:para_client/core/features/injection_container.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:para_client/firebase_options.dart';

Future<void> main() async {
  await initializeDependencies();
  await initHiveForFlutter();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const App());
  });

  // runApp(const App());
}
