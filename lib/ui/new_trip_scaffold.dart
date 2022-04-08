// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutterbasetaxi/api/google_api.dart';
import 'package:flutterbasetaxi/types/resolved_address.dart';
import 'package:flutterbasetaxi/types/trip.dart';
import 'package:flutterbasetaxi/ui/address_search.dart';
import 'package:flutterbasetaxi/providers/assets_loader.dart';
import 'package:flutterbasetaxi/providers/location.dart';
import 'package:flutterbasetaxi/providers/active_trip.dart';
import 'package:flutterbasetaxi/ui/common.dart';
import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/providers/theme.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:async';
import 'package:google_maps_webservice/directions.dart' as dir;

import 'package:google_maps_webservice/places.dart';

import 'package:shimmer/shimmer.dart';

class NewTrip extends StatefulWidget {
  NewTrip({Key? key}) : super(key: key);

  @override
  _NewTripState createState() => _NewTripState();
}

class _NewTripState extends State<NewTrip> {
  LatLngBounds? cameraViewportLatLngBounds;

  ResolvedAddress? from;
  ResolvedAddress? to;

  Polyline? tripPolyline;
  int tripDistanceMeters = 0;
  String tripDistanceText = '';

  Future<void> recalcRoute() async {
    tripPolyline = null;
    tripDistanceText = '';
    tripDistanceMeters = 0;

    if (from == null || to == null) {
      return;
    }
    dir.DirectionsResponse response = await apiDirections
        .directionsWithLocation(from!.location, to!.location);
    if (response.isOkay) {
      tripDistanceMeters =
          response.routes.first.legs.first.distance.value.round();
      tripDistanceText = response.routes.first.legs.first.distance.text;

      if (!response.isOkay) {
        final error =
            'Directions API error. Status: ${response.status} ${response.errorMessage ?? ""}';
        showScaffoldSnackBarMessage(error);

        if (mounted) setState(() {});
      }

      final polylinePoints = createPolylinePointsFromDirections(response)!;

      tripPolyline = Polyline(
          polylineId: PolylineId('polyline-1'),
          width: 5,
          color: Colors.blue,
          points: polylinePoints);
      adjustMapViewBounds();
      if (mounted) setState(() {});
    }
  }

  LatLngBounds? _mapCameraViewBounds;

  void adjustMapViewBounds() {
    if (!mounted) return;

    //0.001 ~= 100 m
    const double deltaLatLngPointBound = 0.0015;

    double minx = 180, miny = 180, maxx = -180, maxy = -180;
    if (from == null && to == null) return;
    if (from == null ||
        to == null ||
        from!.location.lat == to!.location.lat &&
            from!.location.lng == to!.location.lng) {
      double lat = from?.toLatLng.latitude ?? to?.toLatLng.latitude ?? 0;
      double lng = from?.toLatLng.longitude ?? to?.toLatLng.longitude ?? 0;
      minx = lng - deltaLatLngPointBound;
      maxx = lng + deltaLatLngPointBound;
      miny = lat - deltaLatLngPointBound;
      maxy = lat + deltaLatLngPointBound;

      if (minx < -180) minx = -180;
      if (miny < -90) miny = -90;
      if (maxx > 180) minx = 180;
      if (maxy > 90) maxy = 90;
    } else {
      [
        from!.toLatLng,
        to!.toLatLng,
        if (tripPolyline != null) ...tripPolyline!.points
      ].forEach((p) {
        minx = min(minx, p.longitude);
        maxx = max(maxx, p.longitude);

        miny = min(miny, p.latitude);
        maxy = max(maxy, p.latitude);
      });
    }

    final newCameraViewBounds = LatLngBounds(
      northeast: LatLng(maxy, maxx),
      southwest: LatLng(miny, minx),
    );
    if (_mapCameraViewBounds == null ||
        _mapCameraViewBounds != newCameraViewBounds) {
      _mapCameraViewBounds = newCameraViewBounds;

      if (mapControllerCompleter.isCompleted == false) return;

      WidgetsBinding.instance!.addPostFrameCallback((_) {
        if (!mounted || _mapCameraViewBounds == null) return;

        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _mapCameraViewBounds!,
            30,
          ),
        );
      });
    }
  }

  bool isDarkMapThemeSelected = false;
  List<Marker> mapRouteMarkers = List.empty(growable: true);
  List<Marker> avaliableTaxiMarkers = List.empty(growable: true);

  final mapControllerCompleter = Completer<GoogleMapController>();
  GoogleMapController? mapController;
  CameraPosition? _latestCameraPosition;

  void autocompleteAddress(bool isFromAdr, Location searchLocation) async {
    final Prediction? p = await showSearch<Prediction?>(
        context: context,
        delegate: AddressSearch(searchLocation: searchLocation),
        query: (isFromAdr ? from : to)?.mainText ?? '');
    if (p != null) {
      PlacesDetailsResponse placeDetails = await apiGooglePlaces
          .getDetailsByPlaceId(p.placeId!, fields: [
        "address_component",
        "geometry",
        "type",
        "adr_address",
        "formatted_address"
      ]);

      if (!mounted) return;

      final placeAddress = ResolvedAddress(
          location: placeDetails.result.geometry!.location,
          mainText: p.structuredFormatting?.mainText ??
              placeDetails.result.addressComponents.join(','),
          secondaryText: p.structuredFormatting?.secondaryText ?? '');

      setState(() {
        if (isFromAdr)
          from = placeAddress;
        else
          to = placeAddress;
      });

      await recalcRoute();
      adjustMapViewBounds();
      if (mounted) setState(() {});
    }
  }

  void startNewTrip(BuildContext context) {
    final newTrip = TripDataEntity(
        from: from!,
        to: to!,
        polyline: tripPolyline!,
        distanceMeters: tripDistanceMeters,
        distanceText: tripDistanceText,
        mapLatLngBounds: _mapCameraViewBounds!,
        cameraPosition: _latestCameraPosition);

    final demoTripWorkflow = TripProvider.of(context, listen: false);
    demoTripWorkflow.activateTrip(newTrip);
  }

  BitmapDescriptor? fromMarker;
  BitmapDescriptor? toMarker;

  @override
  void initState() {
    from = LocationProvider.of(context, listen: false).currentAddress;
    isDarkMapThemeSelected = false;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    final isDark = ThemeProvider.of(context, listen: false).isDark;
    if (isDark != isDarkMapThemeSelected && mapController != null) {
      mapController!.setMapStyle(ThemeProvider.of(context, listen: false).isDark
          ? googleMapDarkStyle
          : googleMapDefaultStyle);
      isDarkMapThemeSelected = isDark;
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return buildAppScaffold(
      context,
      Container(
          child: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onCameraMove: (pos) => _latestCameraPosition = pos,
              initialCameraPosition: CameraPosition(
                  target: LocationProvider.of(context, listen: false)
                      .currentAddress!
                      .toLatLng,
                  zoom: 15),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              scrollGesturesEnabled: true,
              markers: {
                if (from != null &&
                    AssetLoaderProvider.of(context).markerIconFrom != null)
                  Marker(
                    icon: AssetLoaderProvider.of(context).markerIconFrom!,
                    position: from!.toLatLng,
                    markerId: MarkerId('marker-From' +
                        (kIsWeb
                            ? DateTime.now().toIso8601String()
                            : "")), // Flutter Google Maps for Web does not update marker position properly
                  ),
                if (to != null)
                  Marker(
                    icon: AssetLoaderProvider.of(context).markerIconTo,
                    position: to!.toLatLng,
                    markerId: MarkerId('marker-To' +
                        (kIsWeb ? DateTime.now().toIso8601String() : "")),
                  ),
              },
              polylines: tripPolyline != null
                  ? <Polyline>{tripPolyline!}
                  : const <Polyline>{},
              onMapCreated: (GoogleMapController controller) {
                mapControllerCompleter.complete(controller);
                mapController = controller;
                if (mounted) {
                  final isDark =
                      ThemeProvider.of(context, listen: false).isDark;
                  if (isDark != isDarkMapThemeSelected) {
                    controller.setMapStyle(
                        ThemeProvider.of(context, listen: false).isDark
                            ? googleMapDarkStyle
                            : googleMapDefaultStyle);
                    isDarkMapThemeSelected = isDark;
                  }
                  setState(() {});
                }
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 3,
                  blurRadius: 3,
                  offset: Offset(0, -3), // changes position of shadow
                ),
              ],
            ),
            child: Column(children: [
              ListTile(
                leading: Icon(Icons.person_pin_circle),
                title: Text(
                  from?.mainText ?? "",
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      'From',
                      style: TextStyle(color: Colors.green),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                Theme.of(context).textTheme.bodyText1?.color ??
                                    Colors.white)),
                    Text(from?.secondaryText ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12))
                  ],
                ),
                onTap: () => autocompleteAddress(
                    true,
                    LocationProvider.of(context, listen: false)
                        .currentAddress!
                        .location),
              ),
              SizedBox(
                height: 4,
              ),
              (to == null)
                  ? ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text('To...'),
                      subtitle: Text(''),
                      onTap: () => autocompleteAddress(
                          false,
                          LocationProvider.of(context, listen: false)
                              .currentAddress!
                              .location),
                    )
                  : ListTile(
                      leading: Icon(Icons.location_on_outlined),
                      title: Text(
                        to!.mainText,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            'To',
                            style: TextStyle(color: Colors.green),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Theme.of(context)
                                          .textTheme
                                          .bodyText1
                                          ?.color ??
                                      Colors.white)),
                          Text(to!.secondaryText,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12))
                        ],
                      ),
                      onTap: () => autocompleteAddress(
                          false,
                          LocationProvider.of(context, listen: false)
                              .currentAddress!
                              .location),
                    ),
              Divider(height: 1),
              SizedBox(
                  height: 80,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (from == null || to == null)
                              Shimmer.fromColors(
                                  baseColor: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color ??
                                      Colors.black,
                                  highlightColor:
                                      Theme.of(context).colorScheme.secondary,
                                  child: Text(
                                    'Select destination... ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).hintColor),
                                  )),
                            if (from != null &&
                                to != null &&
                                tripDistanceText.isEmpty)
                              Text(
                                'Calculating route ... ',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                            if (from != null &&
                                to != null &&
                                tripDistanceText.isNotEmpty)
                              Text(
                                'Trip distance: ${tripDistanceText}',
                                style: Theme.of(context).textTheme.subtitle1,
                              ),
                          ],
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                            style: ThemeProvider.of(context).roundButtonStyle,
                            onPressed: (tripDistanceText.isEmpty)
                                ? null
                                : () => startNewTrip(context),
                            child: Row(children: [
                              Icon(Icons.local_taxi),
                              SizedBox(width: 10),
                              Text('Order a taxi')
                            ])),
                      )
                    ],
                  )),
            ]),
          )
        ],
      )),
    );
  }
}
