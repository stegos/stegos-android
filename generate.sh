#!/bin/bash
set -e
set -x
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs