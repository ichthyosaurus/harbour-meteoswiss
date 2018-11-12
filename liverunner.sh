#!/bin/bash
while sleep_until_modified *.qml **/*.qml; do
    killall qml
    qml meteoswiss.qml &
done
