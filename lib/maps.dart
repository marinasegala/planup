import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  final _mapController = MapController(initMapWithUserPosition: true);
  var markerApp = <String, String>{};

  @override
  void initState() {
    super.initState();
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
                color: Colors.amberAccent,
                size: 100,
              ),
            ),
          );
          // Add market to app, for hold information of marker to use it later
          var key = '${position.latitude}_${position.longitude}';
          markerApp[key] = markerApp.length.toString();
        }
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maps'),
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
              Icons.person,
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
          var key = '${geoPoint.latitude}_${geoPoint.longitude}';
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
                            'Position ${markerApp[key]}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const Divider(thickness: 1),
                          Text(key,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
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
