#!/bin/bash

for i in 86 108 128 172; do
    mkdir -p "icons/${i}x$i"
    inkscape -z -e "icons/${i}x$i/harbour-meteoswiss.png" -w "$i" -h "$i" harbour-meteoswiss.svg
done

mkdir -p "qml/weather-icons"
inkscape -z -l "qml/weather-icons/harbour-meteoswiss.svg" harbour-meteoswiss.svg
