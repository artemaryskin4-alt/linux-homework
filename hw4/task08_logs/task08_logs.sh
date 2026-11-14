#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# ==================================================
# task08_logs.sh - массовое создание файлов
# ==================================================
# Использование:
#	./task08_logs.sh
# ==================================================

LOGS_DIR="logs"

echo "=== Массовое создание файлов ==="
echo

# ----- Шаг 1. Cоздать директорию ------

mkdir -p "$LOGS_DIR"
echo "[1] Создана директория: $LOGS_DIR"
echo

# ----- Шаг 2: цикл for - 10 файлов ----
echo "[2] Создаем 10 файлов log01.txt ... log02.txt:"

for i in {1..10}; do
	# Форматируем число с ведущим нулем: 1 -> 01
	num=$(printf "%02d" "$i")
	file="$LOGS_DIR/log_${num}.txt"
	echo "Это лог номер $i" > "$file"
	echo "	Создан: $file"
done

echo


# ----- ШАГ 3: цикл for - вывод содержимого -----
echo "[3] Содержимое всех файлов:"

for file in "$LOGS_DIR"/log_*.txt; do
	echo "--- $file ---"
	cat "$file"
done
echo

# ---- Шаг 4: цикл for + if - удалить четные -----

shopt -s nullglob   # если glob не совпал — пустой список

for file in "$LOGS_DIR"/log_*.txt; do
    basename=$(basename "$file")
    num_str="${basename#log_}"
    num_str="${num_str%.txt}"

    # Защита: проверить, что это число
    if ! [[ "$num_str" =~ ^[0-9]+$ ]]; then
        continue
    fi

    num=$((10#$num_str))

    if (( num % 2 == 0 )); then
        rm "$file"
        echo "  Удалён: $file (номер $num — чётный)"
    fi
done

shopt -u nullglob


