#!/bin/bash
# Автотесты для countdown.sh

SCRIPT="./countdown.sh"

if [ ! -x "$SCRIPT" ]; then
    echo "Ошибка: $SCRIPT не исполняемый"
    exit 1
fi

echo "=== Тест 1: grow, 3 сек (быстро) ==="
DELAY=0.2 "$SCRIPT" 3 grow
echo

echo "=== Тест 2: shrink, 3 сек ==="
DELAY=0.2 "$SCRIPT" 3 shrink
echo

echo "=== Тест 3: fill, 4 сек ==="
DELAY=0.2 "$SCRIPT" 4 fill
echo

echo "=== Тест 4: свой символ и ширина ==="
DELAY=0.2 WIDTH=15 SYMBOL=# "$SCRIPT" 3 grow
echo

echo "=== Тест 5: справка ==="
"$SCRIPT" --help | head -6
echo

echo "=== Тест 6: ошибка — не число ==="
"$SCRIPT" abc 2>&1 || echo "(ожидаемо упал)"
echo

echo "=== Тест 7: ошибка — неверный режим ==="
"$SCRIPT" 5 wrong_mode 2>&1 || echo "(ожидаемо упал)"
echo

echo "Все тесты выполнены."
