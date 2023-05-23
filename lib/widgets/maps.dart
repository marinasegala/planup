import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:planup/db/places_rep.dart';
import 'package:planup/model/places.dart';
import 'package:planup/model/travel.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key, required this.trav});

  final Travel trav;

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

  // list of places
  List<Place> places = [];

  @override
  void initState() {
    super.initState();
    getPlaces();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.listenerMapLongTapping.addListener(() async {
        // when tap on map we will add new marker
        var position = _mapController.listenerMapLongTapping.value;
        if (position != null) {
          await _mapController.addMarker(
            position,
            markerIcon: MarkerIcon(
              icon: Icon(
                Icons.location_on,
                color: Colors.amber[700],
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
              travel: widget.trav.referenceId!,
              callback: addPlace,
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

  Place? getPlace(String lat, String long) {
    return places
        .firstWhere((element) => element.lat == lat && element.long == long);
  }

  void getPlaces() {
    placesRepository.getStream().listen((event) {
      places = event.docs
          .map((e) => Place.fromSnapshot(e))
          .where((element) =>
              element.userid == user.uid &&
              element.travelid == widget.trav.referenceId)
          .toList();
    });
  }

  removePlace(place) {
    setState(() {
      placesRepository.deletePlace(place);
    });
    Navigator.pop(context);
  }

  addPlace(place) {
    setState(() {
      placesRepository.add(place);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            for (var place in places) {
              await _mapController.addMarker(
                GeoPoint(
                    latitude: double.parse(place.lat),
                    longitude: double.parse(place.long)),
                markerIcon: MarkerIcon(
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.amber[700],
                    size: 100,
                  ),
                ),
              );
            }
            if (isReady) {
              await Future.delayed(const Duration(seconds: 1), () async {
                await _mapController.currentLocation();
              });
            }
          },
          onGeoPointClicked: (geoPoint) async {
            // find the point in the database with lat and long and show the information
            var place = getPlace(
                geoPoint.latitude.toString(), geoPoint.longitude.toString());
            if (place != null) {
              // when user click to marker
              showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      CardRemovePlace(place: place, callback: removePlace));
            }
          }),
    );
  }
}

class DialagAddMarker extends StatefulWidget {
  const DialagAddMarker(
      {super.key,
      required this.lat,
      required this.long,
      required this.travel,
      required this.callback});

  final String lat;
  final String long;
  final String travel;
  final Function callback;

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
      scrollable: true,
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
            var description = _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null;
            Place place = Place(
                name: _nameController.text,
                description: description,
                lat: widget.lat,
                long: widget.long,
                userid: user.uid,
                travelid: widget.travel);
            widget.callback(place);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class CardRemovePlace extends StatefulWidget {
  const CardRemovePlace(
      {super.key, required this.place, required this.callback});

  final Place place;
  final Function callback;

  @override
  State<CardRemovePlace> createState() => _CardRemovePlaceState();
}

class _CardRemovePlaceState extends State<CardRemovePlace> {
  PlacesRepository placesRepository = PlacesRepository();

  @override
  Widget build(BuildContext context) {
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
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: Text(
                  widget.place.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Divider(thickness: 1),
              const Text('Descrizione',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(
                  height: 200,
                  child: Center(
                    child: widget.place.description != null
                        ? Text(widget.place.description!,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center)
                        : const Text(
                            'Non hai inserito una descrizione per questo luogo',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                  )),
              TextButton(
                  onPressed: () async {
                    widget.callback(widget.place);
                  },
                  child: const Text('Rimuovi',
                      style: TextStyle(color: Colors.blueGrey)))
            ],
          )),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.clear),
          )
        ],
      ),
    ));
  }
}
