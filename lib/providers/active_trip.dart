// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/types/trip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

// demo trip
class TripProvider with ChangeNotifier {
  TripDataEntity? activeTrip;

  bool get isActive => activeTrip != null;

  Timer? allocatedStateTimer;
  Timer? arrivedStateTimer;
  Timer? drivingStateTimer;
  Timer? completedStateTimer;
  Timer? drivingProgressTimer;

  LatLng? taxiMarkerLatLng;

  LatLng getTaxiDrivePosition(double animationValue) {
    assert(activeTrip != null);
    final points = activeTrip!.polyline.points;
    int pointIndex = ((points.length - 1) * animationValue).round();
    return points[pointIndex];
  }

  void stopTripWorkflow() {
    [
      allocatedStateTimer,
      arrivedStateTimer,
      drivingStateTimer,
      completedStateTimer,
      drivingProgressTimer,
    ].forEach((t) => t?.cancel());
    taxiMarkerLatLng = null;
  }

  void setTripStatus(ExTripStatus newStatus) {
    if (activeTrip == null) return;
    if (tripIsFinished(newStatus)) stopTripWorkflow();
    activeTrip!.status = newStatus;
    notifyListeners();
  }

  void cancelTrip() => setTripStatus(ExTripStatus.cancelled);

  void deactivateTrip() {
    if (activeTrip == null) return;
    if (!tripIsFinished(activeTrip!.status)) {
      cancelTrip();
    }
    activeTrip = null;
    notifyListeners();
  }

  void activateTrip(TripDataEntity trip) {
    stopTripWorkflow();
    activeTrip = trip;
    allocatedStateTimer = Timer(
        Duration(seconds: 1), () => setTripStatus(ExTripStatus.allocated));
    arrivedStateTimer =
        Timer(Duration(seconds: 2), () => setTripStatus(ExTripStatus.arrived));
    final drivingDuration = Duration(seconds: 15);

    drivingStateTimer = Timer(Duration(seconds: 3), () {
      setTripStatus(ExTripStatus.driving);

      final drivingStartTime = DateTime.now();
      final drivingEndTime = DateTime.now().add(drivingDuration);
      completedStateTimer =
          Timer(drivingDuration, () => setTripStatus(ExTripStatus.completed));

      drivingProgressTimer =
          Timer.periodic(Duration(milliseconds: 300), (timer) {
        final now = DateTime.now();
        if (trip.status != ExTripStatus.driving ||
            DateTime.now().compareTo(drivingEndTime) >= 0) {
          timer.cancel();
          return;
        }
        double drivingAnimationValue =
            now.difference(drivingStartTime).inMilliseconds.toDouble() /
                drivingDuration.inMilliseconds.toDouble();
        taxiMarkerLatLng = getTaxiDrivePosition(drivingAnimationValue);
        notifyListeners();
      });
    });

    notifyListeners();
  }

  static TripProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<TripProvider>(context, listen: listen);
}
