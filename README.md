# Flutterbase taxi

A large variety of apps depend on map services. The purpose of this project was to test Google Map Services in connection with Flutter on Android, iOS and Web platforms. Here is what I got:

[Click to open Online Web Demo](https://taxi.flutterbase.com)

https://user-images.githubusercontent.com/100120212/162411043-8621a893-0141-4657-ae9b-4cac77a0fc98.mp4



## Application Structure

The reason I love Flutter is the beauty of its reactive UI nature. Once you've designed an application state correctly, you can design UI at the speed nearly exceeding the speed of light. Altogether, it took me a few days starting from scratch to completing this project.

The recommended way of keeping application state in Flutter is the Provider Pattern. Once the key application screens were defined in Figma, the reactive app state structure became obvious.


![Application Provider's overview](https://github.com/YakivGalkin/flutterbase-taxi/raw/main/docs/providers_overview.png)

After the state design was finalized, I had most pleasant time coding in Dart language :)

## Source Code Documentation

Application structure is fairly straightforward and includes: Providers for the app state, simple wrappers around the Google REST APIs, the standard Flutter GoogleMap widget and the Material UI. That's it. Source code is self explanatory, please refer to standard Flutter documentation. All components are well documented by the Flutter community.

Entire UI workflow fitted in just few lines of code in the 'main.dart' file
```dart
// Get Current Location Provider
final locProvider = LocationProvider.of(context); 

// Get Current Trip Provider
final currentTrip = TripProvider.of(context);     

// if Current location is not known
if (!locProvider.isDemoLocationFixed)             
  // show Location Selection screen     
  return LocationScaffold();                      

// else if there is an Active Trip
if (currentTrip.isActive) {       
  // and if this trip is finished
  return tripIsFinished(currentTrip.activeTrip!.status)
      // show Rate the Trip screen 
      ? tripFinishedScaffold(context)
     // if not finished - show the trip in progress screen     
     : ActiveTrip();
}

// else if there is no active trip - display UI for new trip creation
return NewTrip();
```

## Installation instruction

Clone this git repository and replace the "FLUTTERBASETAXI_API_KEY" text placeholder with your Google Maps API key.

### Android & iOS

Replace the API key, make sure Android and iOS Google Map SDKs are enabled.

### Web

Use any CORS proxy for the Google Places / Direction REST API calls.

## Real life taxi app

The Real taxi app requires development of a scalable server/cloud side storage and logic, authentication, payments, a much more complex workflow/state management, automated testing and deployment, etc. This is just a proof of concept - the sources of this prototype were not used in the production code.

Below are some hints that might be helpful if you decide to go further:

Make sure you can efficiently handle GEO queries on the server side. Google Firestore requires some workarounds to use it properly.

Most payment gateways require user authorization on the native bank web UI. Test if you can integrate it with the Flutter Web View or Flutter deep links callback.

## Thanks

I would like to thank the entire Flutter team and its community for building such an amazing technology for developers. I really enjoy working with Flutter & Dart.

## Get in thought

Email me at [hello@flutterbase.com](mailto:hello@flutterbase.com) or find me on [LinkedIn](https://www.linkedin.com/in/yakiv/).
[www.flutterbase.com](https://flutterbase.com)
