#!/bin/bash

shopt -s nullglob

BINARY="$HOME/termfetch/bin/termfetch"
CC="clang"
CFLAGS="-Wall -Wextra -Isrc/lib"

SRCS=(src/*.c src/lib/terminals/*.c)

if [ ${#SRCS[@]} -eq 0 ]; then
    echo "Ошибка: исходные файлы (.c) не найдены!"
    exit 1
fi

OBJS=("${SRCS[@]/%.c/.o}")

clean() {
    echo "Очистка объектных файлов и бинарника..."
    rm -f "${OBJS[@]}" "$BINARY"
    echo "Очистка завершена."
}

if [ "$1" == "clean" ]; then
    clean
    exit 0
fi

mkdir -p "$(dirname "$BINARY")"

echo "Начинаем компиляцию..."
for i in "${!SRCS[@]}"; do
    src="${SRCS[$i]}"
    obj="${OBJS[$i]}"

    if [ ! -f "$obj" ] || [ "$src" -nt "$obj" ]; then
        echo "  CC  $src -> $obj"
        $CC $CFLAGS -c "$src" -o "$obj"

        if [ $? -ne 0 ]; then
            echo "Ошибка компиляции $src"
            exit 1
        fi
    fi
done

echo "  LD  -> $BINARY"
$CC "${OBJS[@]}" -o "$BINARY"

if [ $? -ne 0 ]; then
    echo "Ошибка линковки!"
    exit 1
fi

echo "Сборка успешно завершена!"
