#!/bin/bash
# Go to the Flutter app directory
cd athletitrack

# Clone the Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to the path
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web support and get dependencies
flutter config --enable-web
flutter pub get

# Build the web app
flutter build web --release
