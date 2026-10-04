#!/bin/bash

# Проверка: ровно 3 аргумента
if [ "$#" -ne 3 ]; then
    echo "Использование: $0 <путь_к_файлу> <текущее_расширение> <желаемое_расширение>"
    echo "Поддерживаются: txt, pdf, doc"
    exit 1
fi

#Объявление переменных
FILE="$1"
OLD_EXT="$2"
NEW_EXT="$3"

#Проверка старого расширения
case "$OLD_EXT" in
	txt|doc|pdf) ;;
	*)
	echo "Ошибка: формат $OLD_EXT не поддерживается"
	echo "Поддерживаются файлы txt, pdf, doc"
	exit 1
	;;
esac

#Проверка нового расширения
case "$NEW_EXT" in
        txt|doc|pdf) ;;
        *)
        echo "Ошибка: формат $OLD_EXT не поддерживается"
        echo "Поддерживаются файлы txt, pdf, doc"
        exit 1
	;;
esac

#Проверка того, что файл существует
if [[ ! -f "$FILE" ]]; then
    echo "Ошибка: файл '$FILE' не найден"
    exit 1
fi

#Отрезаем старое расширение и добавляем новое
BASE="${FILE%.*}"
NEW_FILE="$BASE.$NEW_EXT"

#Переименовываем
if mv "$FILE" "NEW_FILE"; then
	echo "Готово: $FILE → $NEW_FILE"
else
        echo "Ошибка: не удалось переименовать '$FILE'"
	exit 1
fi

