import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:planup/db/location_rep.dart';
import 'package:planup/db/places_rep.dart';
import 'package:planup/db/users_rep.dart';
import 'package:planup/model/location.dart';
import 'package:planup/model/places.dart';
import 'package:planup/model/travel.dart';
import 'package:planup/model/user_account.dart';

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
  LocationRepository locationRepository = LocationRepository();
  UsersRepository usersRepository = UsersRepository();

  // get current user
  User user = FirebaseAuth.instance.currentUser!;

  // list of places
  List<Place> places = [];
  List<Location> locations = [];

  @override
  void initState() {
    super.initState();
    getPlaces();
    getLocations();

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
    var listPlaces =
        places.where((element) => element.lat == lat && element.long == long);
    if (listPlaces.isNotEmpty) {
      return listPlaces.first;
    } else {
      return null;
    }
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

  void getLocations() {
    locationRepository.getStream().listen((event) {
      locations = event.docs
          .map((e) => Location.fromSnapshot(e))
          .where((element) =>
              element.userid != user.uid &&
              element.travelid == widget.trav.referenceId)
          .toList();
    });
  }

  List<Location> getUserLocation(String lat, String long) {
    return locations
        .where((element) =>
            element.lat == lat &&
            element.long == long &&
            element.travelid == widget.trav.referenceId &&
            element.userid != user.uid)
        .toList();
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

  Future<void> displayPlaces() async {
    for (var place in places) {
      await _mapController.addMarker(
        GeoPoint(
            latitude: double.parse(place.lat),
            longitude: double.parse(place.long)),
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.blueGrey[200],
            size: 100,
          ),
        ),
      );
    }
  }

  Future<void> displayLocations() async {
    for (var location in locations) {
      await _mapController.addMarker(
        GeoPoint(
            latitude: double.parse(location.lat),
            longitude: double.parse(location.long)),
        markerIcon: MarkerIcon(
          icon: Icon(
            Icons.location_on,
            color: Colors.blueGrey[200],
            size: 100,
          ),
        ),
      );
    }
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
            await displayPlaces();
            await displayLocations();
            if (isReady) {
              await Future.delayed(const Duration(seconds: 1), () async {
                await _mapController.currentLocation();
              });
            }
          },
          onGeoPointClicked: (geoPoint) async {
            // find the point in the database with lat and long and show the information
            Place? place = getPlace(
                geoPoint.latitude.toString(), geoPoint.longitude.toString());
            if (place != null) {
              // when user click to marker
              showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      CardRemovePlace(place: place, callback: removePlace));
            } else {
              // find the location in the database with userid and travelid and show the information
              List<Location> location = getUserLocation(
                  geoPoint.latitude.toString(), geoPoint.longitude.toString());
              showModalBottomSheet(
                  context: context,
                  builder: (context) => CardLocation(location: location));
            }
          }),
      persistentFooterButtons: [
        // button for add the current user location on database in order to share it with other users
        FloatingActionButton(
            onPressed: () async {
              GeoPoint geoPoint = await _mapController.myLocation();
              var latitude = geoPoint.latitude.toString();
              var longitude = geoPoint.longitude.toString();
              bool isAlreadyShared = await locationRepository.isAlreadyShared(
                  user.uid, widget.trav.referenceId!);
              if (!isAlreadyShared) {
                GeoPoint geoPoint = await _mapController.myLocation();
                var latitude = geoPoint.latitude.toString();
                var longitude = geoPoint.longitude.toString();
                locationRepository.add(Location(
                    latitude, longitude, user.uid, widget.trav.referenceId!));
              } else {
                // update my location on database
                locationRepository.updateLocation(
                    user.uid,
                    widget.trav.referenceId!,
                    Location(latitude, longitude, user.uid,
                        widget.trav.referenceId!));
              }
              // add my location on database
            },
            child: const Column(
              children: [
                Icon(Icons.add),
                Text('Share',
                    style: TextStyle(fontSize: 7), textAlign: TextAlign.center),
              ],
            )),
        // button for remove the current user location on database in order to stop sharing it with other users
        FloatingActionButton(
            onPressed: () async {
              // remove my location on database
              // find the point in the database with lat and long and show the information
              locationRepository.deleteLocation(
                  user.uid, widget.trav.referenceId!);
            },
            child: const Column(
              children: [
                Icon(Icons.remove),
                Text('Remove',
                    style: TextStyle(fontSize: 7), textAlign: TextAlign.center),
              ],
            )),
      ],
      persistentFooterAlignment: AlignmentDirectional.bottomCenter,
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

class CardLocation extends StatefulWidget {
  const CardLocation({super.key, required this.location});

  final List<Location> location;

  @override
  State<CardLocation> createState() => _CardLocationState();
}

class _CardLocationState extends State<CardLocation> {
  UsersRepository usersRepository = UsersRepository();

  List<String> users = [];

  void getUsers(String userid) async {
    usersRepository.getStream().listen((event) {
      var user = event.docs
          .map((e) => UserAccount.fromSnapshot(e))
          .where((element) => element.userid == userid)
          .first
          .name;
      setState(() {
        users.add(user);
      });
    });
    await Future.delayed(const Duration(milliseconds: 50));
  }

  String printUsers() {
    String usersString = '';
    for (var user in users) {
      if (user != users.last) {
        usersString += '$user, ';
      } else if (user == users.last) {
        usersString += user;
      } else if (user == users[users.length - 2]) {
        usersString += '$user e ';
      }
    }
    return usersString;
  }

  @override
  Widget build(BuildContext context) {
    for (var location in widget.location) {
      getUsers(location.userid);
    }
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
                    const SizedBox(height: 10),
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        widget.location.length == 1
                            ? 'Il tuo amico ${users[0]} si trova qui'
                            : 'I tuoi amici ${printUsers()} si trovano qui',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              )
            ]),
      ),
    );
  }
}
