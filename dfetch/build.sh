#!/usr/bin/bash

function build-and-run {
    echo "Сборка кода фетча..."
    
    if [ ! -d "./bin/" ]; then
        mkdir -p ./bin/
    fi
    
    go build -o bin/fetch -ldflags="-s -w" main.go

    echo "запуск фечтa"
    ./bin/fetch
}

function clean {
    rm -f ./bin/fetch
}

build-and-run
