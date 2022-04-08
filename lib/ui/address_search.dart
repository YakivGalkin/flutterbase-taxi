// Project: Flutter-base Taxi
// Purpose: Testing integration of Flutter & Google Maps
// Platforms:  Web, iOS and Android
// Authors: www.flutterbase.com

import 'package:flutter/material.dart';
import 'package:flutterbasetaxi/api/google_api.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:uuid/uuid.dart';

class AddressSearch extends SearchDelegate<Prediction?> {
  final String _sessionToken;
  final Location? searchLocation;
  int searchRadiusMeters;

  AddressSearch(
      {String? sessionToken,
      this.searchLocation,
      this.searchRadiusMeters = 150000})
      : _sessionToken = sessionToken ?? const Uuid().v4();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<PlacesAutocompleteResponse>(
        future: query == ""
            ? null
            : (searchLocation != null
                ? apiGooglePlaces.autocomplete(query,
                    location: searchLocation,
                    radius: searchRadiusMeters,
                    origin: searchLocation,
                    sessionToken: _sessionToken,
                    strictbounds: true)
                : apiGooglePlaces.autocomplete(query,
                    sessionToken: _sessionToken)),
        builder: (context, snapshot) {
          final showMessage = (s) => Container(
                padding: EdgeInsets.all(16.0),
                child: Text(s),
              );

          if (query == '') showMessage('Please enter address');

          if (snapshot.hasError)
            return showMessage(
                'Error occured. ${snapshot.error?.toString() ?? ""}');

          if (!snapshot.hasData) return showMessage('Loading, please wait...');

          if (snapshot.data?.hasNoResults ?? false)
            return showMessage(
                'Address not found. Please refine your search criteria.');

          if (!(snapshot.data?.isOkay ?? false))
            return showMessage(
                'API Error status: ${snapshot.data?.status ?? ""}.  ${snapshot.data?.errorMessage ?? ""}');

          return ListView.builder(
            itemBuilder: (context, index) {
              Prediction p = snapshot.data!.predictions[index];
              return ListTile(
                title: Text(p.structuredFormatting?.mainText ?? ""),
                subtitle: Text((p.structuredFormatting?.secondaryText ?? "")),
                trailing: const Icon(Icons.done),
                onTap: () {
                  close(context, p);
                },
              );
            },
            itemCount: snapshot.data!.predictions.length,
          );
        });
  }
}
