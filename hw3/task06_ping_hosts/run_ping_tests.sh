#!/bin/bash
# Автотесты для ping_hosts.sh

SCRIPT="./ping_hosts.sh"

if [ ! -x "$SCRIPT" ]; then
    echo "Ошибка: $SCRIPT не исполняемый"
    exit 1
fi

echo "=== Тест 1: пинг из файла ==="
"$SCRIPT" hosts.txt
echo

echo "=== Тест 2: пинг из аргументов ==="
"$SCRIPT" 8.8.8.8 localhost
echo

echo "=== Тест 3: с другим таймаутом ==="
TIMEOUT=3 "$SCRIPT" localhost
echo

echo "=== Тест 4: несколько пакетов ==="
COUNT=3 "$SCRIPT" 8.8.8.8
echo

echo "=== Тест 5: справка ==="
"$SCRIPT" --help | head -5
echo

echo "=== Тест 6: ошибка — пустой файл ==="
: > /tmp/empty_hosts.txt
"$SCRIPT" /tmp/empty_hosts.txt 2>&1 || echo "(ожидаемо упал)"
rm -f /tmp/empty_hosts.txt
echo

echo "Все тесты выполнены."
