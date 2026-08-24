#!/usr/bin/bash

function build-and-run {
    cd ./termfetch/

    if [ ! -d "./bin/" ]; then 
        mkdir -p ./bin/
    fi

    ghc ./src/Main.hs -o ./bin/main

    ./bin/main
}

build-and-run
