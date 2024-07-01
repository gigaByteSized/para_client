import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RouteFeedback extends StatefulWidget {
  const RouteFeedback({super.key});

  @override
  State<RouteFeedback> createState() => RouteFeedbackState();
}

class RouteFeedbackState extends State<RouteFeedback> {
  TextEditingController requestTitleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  String? requestTitle;
  String? description;

  @override
  void initState() {
    super.initState();

    requestTitleController.addListener(() {
      setState(() {
        requestTitle = requestTitleController.text;
      });
    });

    descriptionController.addListener(() {
      setState(() {
        description = descriptionController.text;
      });
    });
  }

  @override
  void dispose() {
    requestTitleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route Feedback',
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
                controller: requestTitleController,
                decoration: const InputDecoration(
                  labelText: 'Request title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                maxLines: 9,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText:
                      "Describe your request for route correction or creation. Include as much detail as possible.",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (requestTitle != null && description != null) {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    CollectionReference requests =
                        firestore.collection('_meta-route-feedback');

                    requests.add({
                      'requestTitle': requestTitle,
                      'description': description,
                    }).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Request submitted successfully')),
                      );
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to submit request')),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill in all required fields')),
                    );
                  }
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
