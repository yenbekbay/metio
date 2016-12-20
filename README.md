<img src=".github/hero.png" alt="Metio logo" height="70">

Metio is an iOS app that displays your local weather in a simple, intuitive language.

[![Download on the App Store](https://cdn.rawgit.com/anvilabs/metio/master/.github/appstore-badge.svg)](http://apple.co/2hJ8WLo)

<img src=".github/screenshots.jpg" width="470">

## Stack

Metio iOS app is written in Objective-C using the MVVM architecture. It's built with [ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa), [AFNetworking](https://github.com/AFNetworking/AFNetworking), and [Parse SDK](https://github.com/ParsePlatform/Parse-SDK-iOS-OSX).

## Setup

1. Clone the repo:
```console
$ git clone https://github.com/anvilabs/metio
$ cd metio
```

2. Install iOS app dependencies from [CocoaPods](http://cocoapods.org/#install):
```console
$ (cd ios && bundle install && pod install)
```

6. Configure the secret values for the iOS app:
```console
$ cp ios/Metio/Secrets-Example.h ios/Metio/Secrets.h
$ open ios/Metio/Secrets.h
# Paste your values
```

4. Open the Xcode workspace at `ios/Metio.xcworkspace` and run the app.

## Credits

Loosely based on the [Tropos](https://github.com/thoughtbot/Tropos) project by thoughtbot, inc.

## License

[MIT License](./LICENSE) © Ayan Yenbekbay
