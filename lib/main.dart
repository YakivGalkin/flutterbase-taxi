// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/types/trip.dart';
import 'package:flutterbasetaxi/ui/active_trip_scaffold.dart';
import 'package:flutterbasetaxi/providers/assets_loader.dart';
import 'package:flutterbasetaxi/providers/location.dart';
import 'package:flutterbasetaxi/ui/new_trip_scaffold.dart';
import 'package:flutterbasetaxi/ui/common.dart';
import 'package:flutterbasetaxi/providers/active_trip.dart';
import 'package:flutterbasetaxi/ui/select_location_scaffold.dart';
import 'package:flutterbasetaxi/providers/theme.dart';
import 'package:flutterbasetaxi/ui/trip_finished_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:touch_indicator/touch_indicator.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<AssetLoaderProvider>(
            create: (_) => AssetLoaderProvider()),
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider<TripProvider>(
          create: (_) => TripProvider(),
        )
      ],
      child: Consumer<ThemeProvider>(
          builder: (context, ThemeProvider themeProvider, child) => MaterialApp(
              theme: themeProvider.currentThemeData,
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              builder: (context, child) => TouchIndicator(child: child!),
              home: Builder(
                builder: (ctx) {
                  final locProvider = LocationProvider.of(ctx);
                  final currentTrip = TripProvider.of(ctx);
                  if (!locProvider.isDemoLocationFixed)
                    return LocationScaffold();
                  if (currentTrip.isActive) {
                    return tripIsFinished(currentTrip.activeTrip!.status)
                        ? tripFinishedScaffold(ctx)
                        : ActiveTrip();
                  }
                  return NewTrip();
                },
              ))),
    ));
