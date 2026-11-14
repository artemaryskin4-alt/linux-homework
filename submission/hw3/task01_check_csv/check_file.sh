#!/bin/bash

#Проверка: передан ли аргумент (имя файла)

if [ $# -ne 1 ]; then
    echo "Использование: $0 <файл.csv|файл.tsv>"
    exit 1
fi

FILE="$1"

#Проверка: существует ли файл

if [ ! -f "$FILE" ]; then
    echo "Ошибка: файл '$FILE' не найден"
    exit 1
fi

#Проверяем разделитель по расширению файла
case "$FILE" in
    *.csv) SEP="," ;;
    *.tsv) SEP=$'\t' ;;
    *)
        echo "Ошибка: поддерживаются только .csv и .tsv"
        exit 1
        ;;
esac

echo "Проверяем файл: $FILE"
echo "Разделитель: $([ "$SEP" = "," ] && echo 'запятая' || echo 'табуляция')"
echo "----------------------------------------"

# Счётчики
line_num=0
expected_cols=""
errors=0

# Читаем файл построчно
while IFS= read -r line || [ -n "$line" ]; do
    line_num=$((line_num + 1))

    # Пропускаем пустые строки
    [ -z "$line" ] && continue

    # Считаем количество столбцов через awk
    cols=$(echo "$line" | awk -F"$SEP" '{print NF}')

    if [ -z "$expected_cols" ]; then
        # Первая строка — эталон
        expected_cols=$cols
        echo "Строка $line_num: $cols столбцов (эталон)"
    else
        if [ "$cols" -ne "$expected_cols" ]; then
            echo "Строка $line_num: ОШИБКА! Ожидалось $expected_cols, найдено $cols"
            errors=$((errors + 1))
        else
            echo "Строка $line_num: $cols столбцов — OK"
        fi
    fi
done < "$FILE"

echo "----------------------------------------"
if [ "$errors" -eq 0 ]; then
    echo " Файл корректен. Всего строк: $line_num, столбцов: $expected_cols"
else
    echo " Найдено ошибок: $errors"
    exit 1
fi
