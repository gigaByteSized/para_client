import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/convert_to_dms.dart';
import 'package:para_client/core/services/location_service.dart';
import 'package:para_client/src/destination_selected_map/presentation/choose_on_map.dart';

class AddAlert extends StatefulWidget {
  const AddAlert({super.key});

  @override
  State<AddAlert> createState() => AddAlertState();
}

class AddAlertState extends State<AddAlert> {
  TextEditingController alertNameController = TextEditingController();
  TextEditingController alertNotesController = TextEditingController();

  LatLng? alertLocation;
  LatLng? _initialCenter;
  String? alertName;
  String? alertNotes;
  DateTime? expiryDate;

  @override
  void initState() {
    super.initState();

    getLastKnownLocation().then(
      (value) {
        setState(() {
          _initialCenter = LatLng(value!.latitude, value.longitude);
        });
        return value;
      },
    );

    alertNameController.addListener(() {
      setState(() {
        alertName = alertNameController.text;
      });
    });

    alertNotesController.addListener(() {
      setState(() {
        alertNotes = alertNotesController.text;
      });
    });
  }

  @override
  void dispose() {
    alertNameController.dispose();
    alertNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Alert',
          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: alertNameController,
                decoration: const InputDecoration(
                  labelText: 'Alert name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: alertNotesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Alert notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ListTile(
                title: const Text(
                  'Expiry Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(expiryDate != null
                    ? DateFormat('yyyy-MM-dd').format(expiryDate!)
                    : 'Select a date'),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: expiryDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now()
                        .add(const Duration(days: 30)), // max 30 days
                  );
                  if (pickedDate != null) {
                    setState(() {
                      expiryDate = pickedDate;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              ListTile(
                title: const Text(
                  'Alert location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  alertLocation != null
                      ? '${convertLatLng(alertLocation!.latitude, true)} ${convertLatLng(alertLocation!.longitude, false)}'
                      : 'Select a location',
                  style: const TextStyle(fontSize: 16),
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ChooseOnMap(
                      destination: LatLng(
                          _initialCenter!.latitude, _initialCenter!.longitude),
                      mode: 'destination',
                    );
                  })).then((value) {
                    if (value != null) {
                      setState(() {
                        alertLocation = value;
                      });
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (alertName != null &&
                      alertLocation != null &&
                      expiryDate != null) {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference alerts =
                        firestore.collection('_meta-community-alerts');

                    DateTime ttlDate = DateTime(expiryDate!.year,
                        expiryDate!.month, expiryDate!.day + 1);

                    alerts.add({
                      'alertName': alertName,
                      'alertNotes': alertNotes,
                      'coordinates': GeoPoint(
                          alertLocation!.latitude, alertLocation!.longitude),
                      'expiryDate': Timestamp.fromDate(ttlDate),
                    }).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Alert added successfully')),
                      );
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to add alert')),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all required fields')),
                    );
                  }
                },
                child: const Text('Add alert'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
