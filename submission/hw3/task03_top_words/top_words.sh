#!/bin/bash
set -euo pipefail

N="${2:-10}"
FILE="${1:-}"
STOPWORDS_FILE="${STOPWORDS_FILE:-}"
KEEP_REGISTER="${KEEP_REGISTER:-0}"
MIN_LEN="${MIN_LEN:-1}"

if [ $# -lt 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
Использование: $0 <файл> [N]

Аргументы:
  файл     — текстовый файл для анализа
  N        — сколько слов показать (по умолчанию 10)

Опции (переменные окружения):
  STOPWORDS_FILE=<путь>   файл со стоп-словами
  KEEP_REGISTER=1         учитывать регистр
  MIN_LEN=3               игнорировать слова короче N букв
EOF
    exit 0
fi

if [ ! -f "$FILE" ]; then
    echo "Ошибка: файл '$FILE' не найден" >&2
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "Ошибка: файл '$FILE' пуст" >&2
    exit 1
fi

if ! [[ "$N" =~ ^[0-9]+$ ]] || [ "$N" -lt 1 ]; then
    echo "Ошибка: N должно быть положительным числом, получено '$N'" >&2
    exit 1
fi

if [ -n "$STOPWORDS_FILE" ] && [ ! -f "$STOPWORDS_FILE" ]; then
    echo "Предупреждение: '$STOPWORDS_FILE' не найден — игнорирую" >&2
    STOPWORDS_FILE=""
fi

export LC_ALL=C.utf8

echo "Топ-$N самых частых слов в файле: $FILE"
echo "Настройки: регистр=$([ "$KEEP_REGISTER" -eq 1 ] && echo 'учитывается' || echo 'игнорируется'), мин.длина=$MIN_LEN"
[ -n "$STOPWORDS_FILE" ] && echo "Стоп-слова: $STOPWORDS_FILE"
echo "----------------------------------------"

grep -oP "[\p{L}’'-]+" "$FILE" \
    | { if [ "$KEEP_REGISTER" -eq 1 ]; then cat; else tr '[:upper:]' '[:lower:]'; fi; } \
    | awk -v min="$MIN_LEN" 'length($0) >= min' \
    | { if [ -n "$STOPWORDS_FILE" ]; then grep -vFxf "$STOPWORDS_FILE"; else cat; fi; } \
    | grep -v '^$' \
    | sort \
    | uniq -c \
    | sort -rn \
    | head -n "$N" \
    | awk '{printf "%2d. %-20s %d\n", NR, $2, $1}'

echo "----------------------------------------"
