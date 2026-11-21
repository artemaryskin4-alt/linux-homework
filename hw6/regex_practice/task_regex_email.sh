#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# ============================================================
#  task_regex_email.sh — поиск email с русским доменом (.ru)
# ============================================================
#  Использование:
#     ./task_regex_email.sh <файл>
#     cat file.txt | ./task_regex_email.sh
#
#  Переменные окружения:
#     DOMAIN=ru      домен первого уровня (по умолчанию ru)
#     COUNT_ONLY=1   вывести только количество
#     UNIQUE=1       вывести только уникальные адреса
# ============================================================

DOMAIN="${DOMAIN:-ru}"
COUNT_ONLY="${COUNT_ONLY:-0}"
UNIQUE="${UNIQUE:-0}"


# ---- Справка ----
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
Использование:
  $0 <файл>
  cat file.txt | $0

Переменные окружения:
  DOMAIN=ru      домен первого уровня (по умолчанию ru)
  COUNT_ONLY=1   вывести только количество
  UNIQUE=1       вывести только уникальные адреса

Примеры:
  $0 emails.txt
  DOMAIN=su $0 emails.txt
  COUNT_ONLY=1 $0 emails.txt
EOF
    exit 0
fi

# ---- Определяем источник ----
if [ $# -ge 1 ]; then
    FILE="$1"
    if [ ! -f "$FILE" ]; then
        echo "Ошибка: файл '$FILE' не найден" >&2
        exit 1
    fi
    INPUT="$FILE"
else
    # stdin
    INPUT="/dev/stdin"
fi

# ---- Regex ----
# Имя: буквы, цифры, . _ % + -
# @
# Домен: буквы, цифры, -
# Поддомены: (.что-угодно)*
# .ru в конце
REGEX="[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.ru(?![a-zA-Z0-9.-])"

# ---- Поиск ----
if [ "$COUNT_ONLY" -eq 1 ]; then
    # уникальные адреса, без учёта регистра (приводим к нижнему)
    grep -oiP "$REGEX" "$INPUT" | tr '[:upper:]' '[:lower:]' | sort -u
elif [ "$COUNT_ONLY" -eq 1 ]; then
    count=$(grep -oiP "$REGEX" "$INPUT" | wc -l)
    echo "$count"
else
    grep -oiP "$REGEX" "$INPUT"
fi


