import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:para_client/core/services/location_service.dart';
import 'package:para_client/src/fake_leaflet_map/presentation/leaflet_map.dart';
import 'package:para_client/src/route_selector/presentation/home_menu.dart';
import 'package:para_client/src/search/domain/entities/feature.dart';
import 'package:para_client/widgets/bottom_nav.dart';

class RouteRoot extends StatefulWidget {
  const RouteRoot({super.key, required this.title});

  final String title;

  @override
  State<RouteRoot> createState() => _RouteRootState();
}

class _RouteRootState extends State<RouteRoot> {
  LatLng? origin;

  final List<Widget> _routes = [
    const HomeMenu(),
    // const DedicatedMapViewer()
    const FakeLeafletMap(),
    Container()
    // HomeButtons(),
    // const Text('Saved routes'),
    // const Text('Routes and schedules'),
    // const Text('Community alerts'),
  ];

  int _selectedIndex = 1;

  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    getCurrentLocation().then(
      (value) {
        setState(() {
          LatLng latLng = LatLng(value.latitude, value.longitude);
          origin = latLng;
        });

        // controllerOrigin.text = 'Your location';
        return value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Kabayan,",
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              Text(
                'Sa\'n punta natin ngayon?',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   Padding(
        //     padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
        //     child: InkWell(
        //       borderRadius: BorderRadius.circular(25),
        //       onTap: () {},
        //       child: Ink(
        //         child: const Icon(Icons.account_circle, size: 50),
        //       ),
        //     ),
        //   ),
        // ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SizedBox(
              height: 40,
              child: TextField(
                style: textTheme.displaySmall?.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Search for a destination',
                  hintStyle: textTheme.displaySmall?.copyWith(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                readOnly: true,
                onTap: () => {
                  // Navigator.pushNamed(context, '/mapView',
                  //     arguments: {'destination': null, 'feature': null}),
                  Navigator.pushNamed(context, '/search',
                      arguments: {'mode': 'search'}).then((value) {
                    if (value != null) {
                      Navigator.pushNamed(context, '/mapView', arguments: {
                        'destination': LatLng(
                            (value as Feature).geometry!.coordinates![1],
                            value.geometry!.coordinates![0]),
                        'feature': value,
                      });
                    }
                  })
                  //   Navigator.pushNamed(context, '/mapView', arguments: {
                  //     'destination': LatLng(
                  //         (value as Feature).geometry!.coordinates![1],
                  //         value.geometry!.coordinates![0]),
                  //     'feature': value,
                  //   });

                  // Navigator.pushNamed(context, '/mapView', arguments: {
                  //   'destination': LatLng(
                  //       (value as Feature).geometry!.coordinates![1],
                  //       value.geometry!.coordinates![0]),
                  //   'feature': value,
                  // });
                },
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _routes[_selectedIndex],
      extendBody: _selectedIndex == 0 ? false : true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, -4), // changes position of shadow
            ),
          ],
        ),
        child: MyBottomNavBar(
          // visible: _visible,
          selectedIndex: _selectedIndex,
          onTabChange: (index) {
            // if (index != 1) {
            //   setState(() {
            //     _visible = false;
            //   });
            // }

            if (index == 2) {
              Navigator.pushNamed(context, '/add_alert').then(
                (value) {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              );
            }

            navigateBottomBar(index);
          },
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: !_visible
      //     ? FloatingActionButton(
      //         shape: RoundedRectangleBorder(
      //           borderRadius: BorderRadius.circular(100),
      //         ),

      //         backgroundColor: Theme.of(context).colorScheme.secondary,
      //         foregroundColor: Colors.white,
      //         onPressed: () => {
      //           setState(() => _visible = !_visible),
      //           setState(() {
      //             _selectedIndex = 1;
      //           })
      //         },
      //         // onPressed: () => {Navigator.pushNamed(context, '/mapView')},
      //         // tooltip: 'Increment',
      //         child: const Icon(CupertinoIcons.location_fill),
      //       )
      //     : null,
    );
  }
}
