import 'package:cloud_firestore/cloud_firestore.dart';

class Alert {
  final String id;
  final String alertName;
  final String? alertNotes;
  final GeoPoint coordinates;

  Alert({
    required this.id,
    required this.alertName,
    this.alertNotes,
    required this.coordinates,
  });

  factory Alert.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Alert(
      id: snapshot.id,
      alertName: data['alertName'],
      alertNotes: data['alertNotes'],
      coordinates: data['coordinates'],
    );
  }
}
