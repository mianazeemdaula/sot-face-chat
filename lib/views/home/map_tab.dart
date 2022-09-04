import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_chat/core/const.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapTab extends StatefulWidget {
  const MapTab({Key? key}) : super(key: key);

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  LatLng myPosition = const LatLng(30.673115, 73.649839);

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late BitmapDescriptor mapIcon;

  LatLng destination = const LatLng(30.673115, 73.649839);

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "assets/images/map_icon.png",
    ).then((icon) {
      setState(() {
        mapIcon = icon;
      });
    });
    getPermissionAndLocation();
  }

  Future getPermissionAndLocation() async {
    await Geolocator.requestPermission();

    Position p = await Geolocator.getCurrentPosition();
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      distanceFilter: 1,
    )).listen((event) {
      FirebaseFirestore.instance.collection('users').doc(uid).update({
        'location': GeoPoint(event.latitude, event.longitude),
        "is_live": true,
      });
    });
    FirebaseFirestore.instance
        .collection('users')
        .where('is_live', isEqualTo: true)
        .snapshots()
        .listen((collect) {
      for (var doc in collect.docs) {
        if (doc.data().containsKey('location')) {
          var geo = doc.data()['location'] as GeoPoint;
          setState(() {
            markers[doc.id] = Marker(
              markerId: MarkerId(doc.id),
              position: LatLng(geo.latitude, geo.longitude),
              infoWindow: InfoWindow(
                title: doc.data()['name'],
              ),
              icon: mapIcon,
            );
          });
        }
      }
    });
  }

  Map<String, Marker> markers = {};
  Map<String, Polyline> polyLines = {};
  late GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(30.672710, 73.649142),
            zoom: 16,
          ),
          markers: markers.values.toSet(),
          polylines: polyLines.values.toSet(),
          myLocationEnabled: true,
          compassEnabled: true,
          mapType: MapType.satellite,
          onCameraIdle: () {
            print("On Camera Stop");
          },
          onCameraMove: (position) {
            log(position.target.latitude.toString());
          },
          onTap: (argument) {
            markers['destination'] = Marker(
              markerId: MarkerId('destination'),
              position: argument,
            );
            setState(() {
              destination = argument;
            });
            log("On Location Destinatio Tap");
          },
          padding: const EdgeInsets.symmetric(vertical: 50),
          onMapCreated: (controller) {
            mapController = controller;
            controller.setMapStyle(Const.mapStyle);
          },
          zoomControlsEnabled: false,
        ),
        Row(
          children: [
            IconButton(
              onPressed: () async {
                Position p = await Geolocator.getCurrentPosition();
                mapController.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(p.latitude, p.longitude),
                      zoom: 16,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.atm),
            ),
            IconButton(
              onPressed: () async {
                mapController.setMapStyle(Const.mapStyle);
              },
              icon: Icon(Icons.night_shelter),
            ),
            IconButton(
              onPressed: () async {
                Position p = await Geolocator.getCurrentPosition();
                PolylinePoints polylinePoints = PolylinePoints();
                var results = await polylinePoints.getRouteBetweenCoordinates(
                  "AIzaSyBE0ICU01Uo4vIKNYv90657DD1qqm7YQQg",
                  PointLatLng(p.latitude, p.longitude),
                  PointLatLng(destination.latitude, destination.longitude),
                );
                results.points;
                polyLines['route-1'] = Polyline(
                  polylineId: PolylineId('route-1'),
                  color: Colors.orange,
                  width: 12,
                  endCap: Cap.roundCap,
                  startCap: Cap.roundCap,
                  points: results.points
                      .map((e) => LatLng(e.latitude, e.longitude))
                      .toList(),
                );
                setState(() {});
              },
              icon: Icon(Icons.route),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    FirebaseFirestore.instance.collection('users').doc(uid).update({
      "is_live": false,
    });
    super.dispose();
  }
}
