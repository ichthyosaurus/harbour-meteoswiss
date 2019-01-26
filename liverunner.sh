#!/bin/bash
while sleep_until_modified qml/qchart/*.* qml/*.qml qml/**/*.qml qml/**/**/*.qml qml/js/*.*; do
    killall qml
    qml qml/harbour-meteoswiss.qml &
done
