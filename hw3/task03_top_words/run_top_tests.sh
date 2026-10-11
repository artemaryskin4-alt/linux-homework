#!/bin/bash
# Простые проверки для top_words.sh

SCRIPT="./top_words.sh"
TMP="/tmp/topwords_test_$$"

if [ ! -x "$SCRIPT" ]; then
    echo "Ошибка: $SCRIPT не найден или не исполняемый"
    exit 1
fi

mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT   # убраться при выходе

# --- Тест 1: пустой файл ---
echo "=== Тест 1: пустой файл ==="
: > "$TMP/empty.txt"
"$SCRIPT" "$TMP/empty.txt" || echo "(ожидаемо упал с ошибкой)"
echo

# --- Тест 2: несуществующий файл ---
echo "=== Тест 2: несуществующий файл ==="
"$SCRIPT" "$TMP/nope.txt" || echo "(ожидаемо упал с ошибкой)"
echo

# --- Тест 3: базовый подсчёт ---
echo "=== Тест 3: базовый подсчёт ==="
printf 'the fox and the dog\nThe fox runs.\n' > "$TMP/basic.txt"
"$SCRIPT" "$TMP/basic.txt"
echo

# --- Тест 4: слова с дефисом ---
echo "=== Тест 4: слова с дефисом и апострофом ==="
printf "well-known don't mother-in-law well-known\n" > "$TMP/dash.txt"
"$SCRIPT" "$TMP/dash.txt"
echo

# --- Тест 5: русский текст ---
echo "=== Тест 5: русский текст ==="
printf 'Привет мир привет мама это тест это проверка\n' > "$TMP/ru.txt"
"$SCRIPT" "$TMP/ru.txt"
echo

# --- Тест 6: стоп-слова ---
echo "=== Тест 6: стоп-слова (убираем 'the', 'and') ==="
printf 'the\nand\n' > "$TMP/stop.txt"
STOPWORDS_FILE="$TMP/stop.txt" "$SCRIPT" "$TMP/basic.txt"
echo

# --- Тест 7: KEEP_REGISTER=1 ---
echo "=== Тест 7: KEEP_REGISTER=1 ==="
printf 'The the THE fox\n' > "$TMP/case.txt"
KEEP_REGISTER=1 "$SCRIPT" "$TMP/case.txt"
echo

# --- Тест 8: MIN_LEN=3 ---
echo "=== Тест 8: MIN_LEN=3 (слова короче 3 букв игнорируются) ==="
printf 'a an the cat dog elephant\n' > "$TMP/len.txt"
MIN_LEN=3 "$SCRIPT" "$TMP/len.txt"
echo

echo "Все тесты выполнены."
