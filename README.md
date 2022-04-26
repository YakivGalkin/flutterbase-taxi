# Flutterbase taxi

A large variety of apps depend on map services. The purpose of this project was to test Google Map Services in connection with Flutter on Android, iOS and Web platforms. Here is what I got:


![App Demo Images](https://github.com/YakivGalkin/flutterbase-taxi/raw/main/docs/taxi_demo_image.png)


### [Click to open Online Web Demo](https://taxi.flutterbase.com)

## Real life taxi app

The Real taxi app requires development of a scalable server/cloud side storage and logic, authentication, payments, a much more complex workflow/state management, automated testing and deployment, etc. This is just a proof of concept - the sources of this prototype were not used in the production code.

## Installation instruction

Clone the flutterbase taxi application source code repository:

```
git clone https://github.com/YakivGalkin/flutterbase-taxi
cd flutterbase-taxi
```

Install Flutter dependencies

```
flutter pub get
```

### Web

Create Google Cloud API key with the following APIs enabled:

* Maps Javascript API
* Places API
* Directions API
* Geocoding API

Replace the __FLUTTERBASETAXI_API_KEY__ text placeholder with your Google API key in the following files: 
* lib/api/google_api.dart
* web/index.html

Google Places APIs and Directions API cannot be used in browsers due to the CORS rules violation. As a workaround I deployed a simple CORS proxy server running in the google cloud. Path to this server s sored in 'prodApiProxy' variable declared in the 'lib/api/google_api.dart' file.


### Android & iOS

Replace the __FLUTTERBASETAXI_API_KEY__ text placeholder with your Google API key in the /ios/* and /android/* project folders, make sure the following APIs are enabled:


* Maps SDK for Android
* Maps SDK for iOS
* Places API
* Directions API
* Geocoding API


## Application Structure

The reason I love Flutter is the beauty of its reactive UI nature. Once you've designed an application state correctly, you can design UI at the speed nearly exceeding the speed of light. Altogether, it took me a few days starting from scratch to completing this project.

The recommended way of keeping application state in Flutter is the Provider Pattern. Once the key application screens were defined in Figma, the reactive app state structure became obvious.


![Application Provider's overview](https://github.com/YakivGalkin/flutterbase-taxi/raw/main/docs/providers_overview.png)

After the state design was finalized, I had most pleasant time coding in Dart language :)

## Source Code Documentation

Application structure is fairly straightforward and includes: Providers for the app state, simple wrappers around the Google REST APIs, the  Flutter GoogleMap widget and the standard Material UI. That's it. Source code is self explanatory, please refer to standard Flutter documentation. All components are well documented by the Flutter community.

Entire UI workflow fitted in just few lines of code located in the 'main.dart' file
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

## Some hints on further development

Below are some hints that might be helpful if you decide to go further:

Make sure you can efficiently handle GEO queries on the server side. Google Firestore requires some workarounds to use it properly.

Most payment gateways require user authorization on the native bank web UI. Test if you can integrate it with the Flutter Web View or Flutter deep links callback.

## Thanks

I would like to thank the entire Flutter team and its community for building such an amazing technology for developers. I really enjoy working with Flutter & Dart.

## Get in thought

Calling all Flutter enthusiasts - connect me on [LinkedIn](https://www.linkedin.com/in/yakiv/) :)



