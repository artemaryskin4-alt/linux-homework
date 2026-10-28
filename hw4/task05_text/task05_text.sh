#!/bin/bash

set -euo pipefail
export LC_ALL=C.utf8

# ============================================================
#  task05_text.sh — анализ текстовых данных
# ============================================================
#  Использование:
#     ./task05_text.sh [text.txt]
#
#  По умолчанию читает ./text.txt
# ============================================================

TEXT="${1:-text.txt}"
API_BASE="https://api.dictionaryapi.dev/api/v2/entries/en"

if [ ! -f "$TEXT" ]; then
    echo "Ошибка: файл '$TEXT' не найден" >&2
    exit 1
fi

echo "=== Анализ текста: $TEXT ==="
echo

# ---- Шаг 1: sed — нижний регистр + удалить пунктуацию ----
echo "[1] Очистка текста (нижний регистр, без пунктуации):"
tr '[:upper:]' '[:lower:]' < "$TEXT" \
    | sed 's/[[:punct:]]//g' \
    > /tmp/text_cleaned.txt

echo "Первые строки:"
head -3 /tmp/text_cleaned.txt
echo

# ---- Шаг 2: awk — ТОП-5 слов ----
echo "[2] ТОП-5 самых частых слов:"

awk '{
    n = split($0, words, /[[:space:]]+/)
    for (i = 1; i <= n; i++) {
        w = words[i]
        if (w != "") count[w]++
    }
}
END {
    for (w in count) print count[w], w
}' /tmp/text_cleaned.txt | sort -rn | head -5 > /tmp/top5.txt

# Вывести в формате «Слово: Количество»
awk '{ printf "  %s: %d\n", $2, $1 }' /tmp/top5.txt
echo

# ---- Шаг 3: for + curl — определения ----
echo "[3] Определения для ТОП-5 слов (через $API_BASE):"

mkdir -p definitions

# Извлечь только слова
top5_words=$(awk '{ print $2 }' /tmp/top5.txt)

for word in $top5_words; do
    echo "=== $word ==="
    url="$API_BASE/$word"
    # Запрос к API
    if curl -s -f "$url" > "definitions/$word.json" 2>/dev/null; then
        # Успех — извлекаем определение (грубо, через grep)
        definition=$(grep -oP '"definition":\s*"\K[^"]+' "definitions/$word.json" | head -1)
        if [ -n "$definition" ]; then
            echo "  $definition"
        else
            echo "  (определение не найдено, но ответ сохранён)"
        fi
    else
        echo "  (не удалось получить определение)"
    fi
    echo
done

rm -f /tmp/text_cleaned.txt /tmp/top5.txt

echo "=== Готово ==="
