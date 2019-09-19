import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);
  var location = new Location();
  var permissionGranted = false;
  var isLoading = false;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text('Maps Flutter App'),
          ),
          body: Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                myLocationEnabled: permissionGranted == false ? false : true,
              ),
              ModalProgressHUD(child: Container(
                  
              ), inAsyncCall: isLoading),
            ],
          )),
      theme: ThemeData(primaryColor: Colors.black),
    );
  }

  void requestPermission() async {
    if (!await location.hasPermission()) {
      await location.requestPermission().then((granted) {
        setState(() {
          permissionGranted = granted;
        });
        if (granted) {
          getCurrentLocation();
        }
      });
    } else {
      setState(() {
        permissionGranted = true;
      });

      getCurrentLocation();
    }
  }

  void getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    await location.getLocation().then((location) {
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude), 17));
        Fluttertoast.showToast(msg: "Showing current location");
        setState(() {
          isLoading = false;
        });
      }
    });
  }
}
