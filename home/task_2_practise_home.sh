#!/bin/bash

# Проверка: ровно 2 аргумента
if [ "$#" -ne 2 ]; then
    echo "Использование: $0 <файл> <организм>" >&2
    echo "Поддерживаемые организмы: human, mouse, rat, fly" >&2
    exit 1
fi

FILE="$1"
ORGANISM="$2"

# Проверка организма
case "$ORGANISM" in
    human|mouse|rat|fly)
        ;;
    *)
        echo "Ошибка: организм '$ORGANISM' не поддерживается." >&2
        echo "Список поддерживаемых организмов: human, mouse, rat, fly" >&2
        exit 1
        ;;
esac

# Проверка файла
if [ ! -f "$FILE" ]; then
    echo "Ошибка: файла '$FILE' не существует" >&2
    exit 1
fi

# Всё ок — обрабатываем
echo "Обрабатываю $FILE"
