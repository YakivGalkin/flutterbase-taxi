// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/providers/location.dart';

import 'main_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showScaffoldSnackBar(SnackBar snackBar) =>
    rootScaffoldMessengerKey.currentState?.showSnackBar(snackBar);

void showScaffoldSnackBarMessage(String message) =>
    rootScaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(message)));

void launchUrl(String url) async {
  if (!await launch(url))
    showScaffoldSnackBarMessage('Could not open url: "$url"');
}

Widget buildAppScaffold(BuildContext context, Widget child,
    {isLoggedIn = true}) {
  final isLocationFixed = LocationProvider.of(context).isDemoLocationFixed;
  return Scaffold(
    floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    floatingActionButton: Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: FloatingActionButton(
          mouseCursor: SystemMouseCursors.click,
          child: Icon(
            Icons.menu,
          ),

          onPressed: () =>
              Scaffold.of(context).openDrawer(), // <-- Opens drawer.
        ),
      );
    }),
    drawer: mainDrawer(context, isLoggedIn: isLoggedIn),
    body: SafeArea(child: child),
  );
}
