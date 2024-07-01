import 'package:flutter/material.dart';
import 'package:para_client/widgets/button_primitives/home_card_button.dart';
import 'package:para_client/widgets/shim.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            const Shim(height: 30),
            HomeCardButton(
              titleText: "Plan a trip",
              cardIcon: Icons.arrow_forward_ios,
              height: 150,
              isAccent: true,
              onTap: () => {
                Navigator.pushNamed(context, '/plan'),
              },
            ),
            // const Shim(height: 20),
            // HomeCardButton(
            //   titleText: "Saved\nroutes",
            //   cardIcon: Icons.map_outlined,
            //   height: 180,
            //   onTap: () => {print("Saved routes tapped")},
            // ),
            // const Shim(height: 20),
            // HomeCardButton(
            //   titleText: "Routes and\nschedules",
            //   cardIcon: Icons.event_outlined,
            //   height: 180,
            //   onTap: () => {print("Routes and schedules tapped")},
            // ),
            const Shim(height: 20),
            HomeCardButton(
              titleText: "Community\nalerts",
              cardIcon: Icons.notifications_outlined,
              height: 180,
              onTap: () => {
                Navigator.pushNamed(context, '/alerts_page'),
              },
            ),
            const Shim(height: 20),
            HomeCardButton(
              titleText: "Request a\nroute",
              cardIcon: Icons.feedback_outlined,
              height: 180,
              onTap: () => {
                Navigator.pushNamed(context, '/route_feedback'),
              },
            ),
          ],
        ),
      ),
    );
  }
}
