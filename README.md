# Flutterbase taxi

A huge variety of apps depend on map services. The purpose of this project was to test Google Map Services in connection with Flutter on Android, iOS and Web platforms. Here is what i got:

![Demo Video](https://github.com/YakivGalkin/flutterbase-taxi/blob/main/docs/taxi_demo_video.mp4?raw=true)

## Application Structure

The reason I love Flutter so much is the beauty of its reactive UI nature. Once you design an application state correctly - the UI development speed becomes something that almost exceeds the speed of light. All in all I spent just a few days on this project starting it from scratch.

The most standard way of keeping application state in Flutter is a Provider pattern.
Once the key application screens were defined in Figma, the reactive app state structure became obvious.

![Application Provider's overview](https://github.com/YakivGalkin/flutterbase-taxi/raw/main/docs/providers_overview.png)

After the state was finalised, nothing could stop me from the most pleasant time - coding in Dart language :)
Source Code Documentation

Application structure is fairly straightforward - Providers for the app state, simple wrappers on the Google REST APIs, the standard Flutter GoogleMap widget and the Material UI. That's it. Source code is self explanatory, please address all issues to standard flutter documentation. All of the components are well documented by the Flutter community.

## Installation instruction

Clone this git repository and replace the "_FLUTTERBASETAXI_API_KEY_" text placeholder with your Google Maps API key

### Android & iOS

Just replace the API key; make sure Android and/or iOS Google Map SDKs are enabled

### Web

Please use CROS proxy for the Google Places / Direction REST API calls.

## Real life taxi app

The Real taxi app requires development of a scalable server/cloud side storage and logic, authentication, payments, much more complex workflow/state management, automated testing and deployment, etc. After all, you will probably notice that no sources from this prototype become a part of a production code.

Below are some hints that might be helpful if you decide to go further:
Make sure you can efficiently handle GEO queries on the server side. Google Firestore requires some workarounds to do it properly.
Most payment gateways require user authorisation on the native bank web ui. Test if you can integrate it with the Flutter Web View or Flutter deep links callback.

## Thanks

I would like to take an opportunity and say big thanks to all the Flutter team and its community for building such amazing technology for developers. I really enjoy working with Flutter & Dart.

## Get in thought

Email me at [hello@flutterbase.com](mailto:hello@flutterbase.com) or find me on [LinkedIn](https://www.linkedin.com/in/yakiv/).
