// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/providers/active_trip.dart';
import 'package:flutterbasetaxi/providers/location.dart';
import 'package:flutterbasetaxi/providers/theme.dart';
import 'package:flutterbasetaxi/ui/common.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

Widget mainDrawer(BuildContext context, {bool isLoggedIn = true}) => Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: Expanded(
                        child:
                            Lottie.asset('assets/lottie/taxi-animation.json')),
                  ),
                  Text(
                    "Flutterbase Taxi",
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        ?.copyWith(color: Colors.black),
                  ),
                ],
              )),
          ListTile(
            leading: const Icon(Icons.local_taxi),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Toggle theme'),
            onTap: () {
              final tp = Provider.of<ThemeProvider>(context, listen: false);
              tp.isDark = !tp.isDark;
              Navigator.pop(context);
            },
          ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
                  TripProvider.of(context, listen: false).deactivateTrip();
                  LocationProvider.of(context, listen: false).reset();
                });
                Navigator.pop(context);
              },
            ),
          const Divider(
            height: 10,
            thickness: 1,
          ),
          ListTile(
            title: const Text('Connect with Developer'),
            subtitle: Text(
              'www.linkedin.com/in/yakiv/',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              launchUrl('https://www.linkedin.com/in/yakiv/');
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Get Full Source Code'),
            subtitle: Text(
              'github.com/YakivGalkin/flutterbase_taxi',
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () {
              launchUrl('https://github.com/YakivGalkin/flutterbase_taxi');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
