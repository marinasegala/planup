import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:planup/db/places_rep.dart';
import 'package:planup/model/places.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  // controller for map
  final _mapController = MapController(initMapWithUserPosition: true);

  var markerApp = <String, String>{};

  // repository for places data
  PlacesRepository placesRepository = PlacesRepository();

  // get current user
  User user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    const Color amber900 = Color(0xFFFF8F00);
    const pinColor = amber900;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.listenerMapLongTapping.addListener(() async {
        // when tap on map we will add new marker
        var position = _mapController.listenerMapLongTapping.value;
        if (position != null) {
          await _mapController.addMarker(
            position,
            markerIcon: const MarkerIcon(
              icon: Icon(
                Icons.location_on,
                color: pinColor,
                size: 100,
              ),
            ),
          );
          // Add market to app, for hold information of marker to use it later
          var key = '${position.latitude}_${position.longitude}';
          markerApp[key] = markerApp.length.toString();

          // open a pop up to get name of marker
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (context) => DialagAddMarker(
              lat: position.latitude.toString(),
              long: position.longitude.toString(),
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Place? getPlace(var lat, var long) {
    Place? place;
    placesRepository.getStream().listen((event) {
      place = event.docs
          .map((e) => Place.fromSnapshot(e))
          .where((element) => element.lat == lat && element.long == long)
          .first;
    });
    return place;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Mappa'),
      ),
      body: OSMFlutter(
        controller: _mapController,
        mapIsLoading: const Center(child: CircularProgressIndicator()),
        trackMyPosition: true,
        initZoom: 14,
        minZoomLevel: 2,
        maxZoomLevel: 19,
        stepZoom: 1.0,
        androidHotReloadSupport: true,
        roadConfiguration: const RoadOption(roadColor: Colors.blueGrey),
        userLocationMarker: UserLocationMaker(
          personMarker: const MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.blueGrey,
              size: 100,
            ),
          ),
          directionArrowMarker: const MarkerIcon(
            icon: Icon(Icons.location_on, color: Colors.blueGrey, size: 100),
          ),
        ),
        markerOption: MarkerOption(
            defaultMarker: const MarkerIcon(
          icon: Icon(Icons.person_pin_circle_outlined,
              color: Colors.black, size: 50),
        )),
        onMapIsReady: (isReady) async {
          if (isReady) {
            await Future.delayed(const Duration(seconds: 1), () async {
              await _mapController.currentLocation();
            });
          }
        },
        onGeoPointClicked: (geoPoint) {
          // find the point in the database with lat and long and show the information
          var place = getPlace(geoPoint.latitude, geoPoint.longitude);
          // when user click to marker
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Card(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            place!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Divider(thickness: 1),
                          place.description != null
                              ? Text(place.description!,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey))
                              : const Text('No description',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey))
                        ],
                      )),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.clear),
                      )
                    ],
                  ),
                ));
              });
        },
      ),
    );
  }
}

class DialagAddMarker extends StatefulWidget {
  const DialagAddMarker({super.key, required this.lat, required this.long});

  final String lat;
  final String long;

  @override
  State<DialagAddMarker> createState() => _DialagAddMarkerState();
}

class _DialagAddMarkerState extends State<DialagAddMarker> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  PlacesRepository placeRepository = PlacesRepository();
  User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Marker'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Lat: ${widget.lat}'),
          Text('Long: ${widget.long}'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              icon: Icon(Icons.place_outlined),
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
            validator: (value) => value!.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              icon: Icon(Icons.description_outlined),
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            placeRepository.add(Place(
                name: _nameController.text,
                description: _descriptionController.text,
                lat: widget.lat,
                long: widget.long,
                userid: user.uid,
                travelid: '0'));
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
