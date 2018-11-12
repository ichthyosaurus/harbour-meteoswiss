#!/bin/bash
while sleep_until_modified *.qml **/*.qml **/**/*.qml data/*.*; do
    killall qml
    qml meteoswiss.qml &
done
