#!/bin/sh

./gradlew properties --no-daemon --console=plain -q | awk '/^version:/ {printf $2}'