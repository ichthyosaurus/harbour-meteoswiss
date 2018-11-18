#!/bin/bash
while sleep_until_modified *.qml **/*.qml **/**/*.qml js/*.*; do
    killall qml
    qml meteoswiss.qml &
done
