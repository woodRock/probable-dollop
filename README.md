# Stock
[![Flutter](https://github.com/woodRock/probable-dollop/actions/workflows/flutter.yml/badge.svg)](https://github.com/woodRock/probable-dollop/actions/workflows/flutter.yml)

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Tutorial from Flutter Docs

Currently this project is an implementation of the [tutorial](https://docs.flutter.dev/get-started/codelab
) from the flutter docs.

## Build Android APK

We can build an android APK for the application that can be downloaded and installed on android devices for offline use. The APK is the release version of the application, and can be found in the `build/app/outputs/flutter-apk/app-release.apk` here.

```bash
$ flutter build apk
```

## Setup Development environment

First we install the java sdk.

```bash
$ sudo apt install openjdk-11-jdk
```

Then we install android studio.

```bash
$ sudo snap install android-studio --classic
```

Then we install flutter.

```bash
$ sudo apt-get install flutter -classic
```

Then we test the installation. All ticks should be green.

```bash
$ flutter doctor
```
