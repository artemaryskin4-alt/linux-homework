#!/bin/bash

read -p "Введите аргумент (-u или -l): " argument
read -p "Введите слово: " word

if [[ "$argument" == "-u" ]]; then
	echo "${word^^}"
elif [[ "$argument" == "-l" ]]; then
	echo "${word,,}"
else
	echo "Неизвестный аргумент $argument"
	exit 1
fi
