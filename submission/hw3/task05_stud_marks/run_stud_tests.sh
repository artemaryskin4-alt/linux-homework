#!/bin/bash
# Автотесты для students_filter.sh

SCRIPT="./students_filter.sh"
TMP="/tmp/stud_tests_$$"

if [ ! -x "$SCRIPT" ]; then
    echo "Ошибка: $SCRIPT не исполняемый"
    exit 1
fi

mkdir -p "$TMP"
trap 'rm -rf "$TMP"' EXIT

# Тестовый файл
cat > "$TMP/g.csv" <<'DATA'
Иванов Иван,4,Математика
Петров Пётр,5,Физика
Сидорова Анна,3,Математика
Кузнецов Олег,5,Математика
DATA

echo "=== Тест 1: порог 4, строго > ==="
"$SCRIPT" "$TMP/g.csv" 4

echo
echo "=== Тест 2: порог 4, включая равные ==="
INCLUDE_EQUAL=1 "$SCRIPT" "$TMP/g.csv" 4

echo
echo "=== Тест 3: порог 5, строго > (никого) ==="
"$SCRIPT" "$TMP/g.csv" 5

echo
echo "=== Тест 4: SORT_BY=name ==="
SORT_BY=name "$SCRIPT" "$TMP/g.csv" 3

echo
echo "=== Тест 5: ошибка — порог не число ==="
"$SCRIPT" "$TMP/g.csv" abc || echo "(ожидаемо упал)"

echo
echo "=== Тест 6: ошибка — файл не найден ==="
"$SCRIPT" "$TMP/nope.csv" 4 || echo "(ожидаемо упал)"

echo
echo "Все тесты выполнены."
