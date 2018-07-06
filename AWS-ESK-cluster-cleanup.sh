#!/bin/bash

if [ "$#" -ne "1" ]; then
    echo -e "Please provide cluster name"
    exit 1
fi

echo -e "START K8s removal"
./build/bin/kontainer-engine_darwin-amd64 rm $1
echo -e "END K8s removal"
