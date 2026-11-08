#!/bin/bash

set -e  

PROJECT_NAME="DexCPP"
CXX="clang++"
CXX_STANDARD="c++17"
BINARY="$PROJECT_NAME"

CXXFLAGS="-std=$CXX_STANDARD -Wall -Wextra -D_XOPEN_SOURCE=600 -D_DEFAULT_SOURCE"

shopt -s nullglob
SOURCES=(src/**/*.cpp)

if [ ${#SOURCES[@]} -eq 0 ]; then
    echo "Ошибка: исходные файлы (.cpp) не найдены в src/"
    exit 1
fi

OBJECTS=("${SOURCES[@]/%.cpp/.o}")

if ! command -v pkg-config &> /dev/null; then
    echo "Ошибка: pkg-config не найден. Установите pkg-config."
    exit 1
fi

if ! pkg-config --exists ncursesw; then
    echo "Ошибка: ncursesw не найден. Установите libncursesw-dev или ncurses-devel."
    exit 1
fi

CURSES_CFLAGS=$(pkg-config --cflags ncursesw)
CURSES_LIBS=$(pkg-config --libs ncursesw)

clean() {
    echo "Очистка объектных файлов и бинарника..."
    rm -f "${OBJECTS[@]}" "$BINARY"
    echo "Очистка завершена."
}

if [ "$1" == "clean" ]; then
    clean
    exit 0
fi

echo "Начинаем компиляцию $PROJECT_NAME (компилятор: $CXX)..."

for obj in "${OBJECTS[@]}"; do
    mkdir -p "$(dirname "$obj")"
done

for i in "${!SOURCES[@]}"; do
    src="${SOURCES[$i]}"
    obj="${OBJECTS[$i]}"
    
    if [ ! -f "$obj" ] || [ "$src" -nt "$obj" ]; then
        echo "  CXX $src -> $obj"
        $CXX $CXXFLAGS $CURSES_CFLAGS -c "$src" -o "$obj"
        
        if [ $? -ne 0 ]; then
            echo "Ошибка компиляции $src"
            exit 1
        fi
    fi
done

echo "  LD  -> $BINARY"
$CXX "${OBJECTS[@]}" $CURSES_LIBS -o "$BINARY"

if [ $? -ne 0 ]; then
    echo "Ошибка линковки!"
    exit 1
fi

echo "Сборка $PROJECT_NAME успешно завершена!"
echo "Исполняемый файл: ./$BINARY"
