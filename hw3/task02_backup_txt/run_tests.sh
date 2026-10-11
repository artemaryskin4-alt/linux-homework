#!/bin/bash
# Простые тесты для backup_txt.sh

SCRIPT="./backup_txt.sh"
TMP="/tmp/backup_test_$$"   # $$ = PID, уникальное имя на каждый запуск

# Проверка, что скрипт вообще существует и исполняемый
if [ ! -x "$SCRIPT" ]; then
    echo "Ошибка: $SCRIPT не найден или не исполняемый"
    echo "Сделай: chmod +x $SCRIPT"
    exit 1
fi

# Сохраняем исходную директорию, чтобы вернуться
ORIG_DIR=$(pwd)

# Готовим чистую временную папку
rm -rf "$TMP" && mkdir -p "$TMP"
cd "$TMP" || exit 1

echo "=== Тест 1: пустая папка ==="
"$ORIG_DIR/$SCRIPT" "$TMP"
echo

echo "=== Тест 2: файлы разных типов ==="

touch notes.txt "my report.txt" data.md README
"$ORIG_DIR/$SCRIPT" "$TMP"
echo "Содержимое backup/:"
ls backup/
echo

echo "=== Тест 3: повторный запуск (идемпотентность) ==="
"$ORIG_DIR/$SCRIPT" "$TMP"
echo

echo "=== Тест 4: несуществующая папка ==="
"$ORIG_DIR/$SCRIPT" /tmp/does_not_exist_$$
echo "Код возврата: $?"
echo

echo "=== Тест 5: рекурсия с флагом -r ==="
mkdir -p "$TMP/sub"
echo "deep content" > "$TMP/sub/deep.txt"
echo "-- без -r (deep.txt НЕ должен появиться в backup/):"
"$ORIG_DIR/$SCRIPT" "$TMP"
echo "-- с -r (deep.txt должен появиться):"
"$ORIG_DIR/$SCRIPT" -r "$TMP"
echo

echo "=== Тест 6: флаг -t (дата+время) ==="
"$ORIG_DIR/$SCRIPT" -t "$TMP"
ls backup/
echo

# Убираемся
cd "$ORIG_DIR" || exit 1
rm -rf "$TMP"
echo "Все тесты пройдены."
