#!/bin/bash

# Проверка: передан ровно 1 аргумент
if [ "$#" -ne 1 ]; then
    echo "Ошибка: нужно ровно 1 аргумент — путь до файла" >&2
    echo "Использование: $0 <путь_до_файла>" >&2
    exit 1
fi

PATH_FILE="$1"

# Проверка существования файла
if [ ! -f "$PATH_FILE" ]; then
    echo "Ошибка: файл '$PATH_FILE' не найден" >&2
    exit 1
fi

# Извлекаем расширение из пути
EXT_FILE="${PATH_FILE##*.}"

# Проверка расширения
case "$EXT_FILE" in
    fa|fasta)
        echo "Файл '$PATH_FILE' является FASTA"
        ;;
    *)
        echo "Ошибка: файл '$PATH_FILE' не относится к формату FASTA" >&2
        exit 1
        ;;
esac
