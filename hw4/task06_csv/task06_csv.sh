#!/bin/bash
set -euo pipefail
export LC_ALL=C.utf8

CSV="${1:-data.csv}"

if [ ! -f "$CSV" ]; then
    echo "Ошибка: файл '$CSV' не найден" >&2
    exit 1
fi

echo "=== Валидация и исправление CSV: $CSV ==="
echo

# ---- Шаг 1: tr — замена ; на , ----
echo "[1] Исправляем файл (; → ,):"
tr ';' ',' < "$CSV" > /tmp/data_fixed.csv
echo "Результат:"
cat /tmp/data_fixed.csv
echo

# ---- Шаг 2: awk — валидация ----
echo "[2] Проверка валидности (3 поля в каждой строке):"
awk -F',' 'NR > 1 {
    if (NF != 3) {
        printf "  Строка %d: %d полей — ОШИБКА: %s\n", NR, NF, $0
        errors++
    } else {
        printf "  Строка %d: %d полей — OK\n", NR, NF
    }
}

END {
    if (errors > 0) {
        printf "\nВсего ошибок: %d\n", errors
    } else {
        printf "\nВсе строки валидны.\n"
    }
}' /tmp/data_fixed.csv
echo

# ---- Шаг 3: while + awk — предложения ----
echo "[3] Предложения для каждой записи:"
tail -n +2 /tmp/data_fixed.csv | while IFS=',' read -r name age city; do
    name="${name//\"/}"
    age="${age//\"/}"
    city="${city//\"/}"
    awk -v n="$name" -v a="$age" -v c="$city" 'BEGIN {
        printf "  Hello, my name is %s. I am %s years old and I live in %s.\n", n, a, c
    }'
done
rm -f /tmp/data_fixed.csv
echo
echo "=== Готово ==="
