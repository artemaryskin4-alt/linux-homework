#!/bin/bash

# 1. Проверка аргументов
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <путь>" >&2
    exit 1
fi

PATH_TARGET="$1"

# 2. Проверка существования
if [ ! -e "$PATH_TARGET" ]; then
    echo "Ошибка: '$PATH_TARGET' не существует" >&2
    exit 1
fi

# 3. Директория?
if [ -d "$PATH_TARGET" ]; then
    echo "Это директория. Содержимое:"
    ls -la "$PATH_TARGET"
    exit 0
fi

# 4. Файл?
if [ -f "$PATH_TARGET" ]; then
    echo "Это файл. Подробная информация:"
    ls -l "$PATH_TARGET"
    echo "Число строк:"
    wc -l < "$PATH_TARGET"
    exit 0
fi

# 5. Что-то другое (симлинк, сокет и т.п.)
echo "Ошибка: '$PATH_TARGET' — не файл и не директория" >&2
exit 1


