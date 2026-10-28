#!/bin/bash

set -eou pipefail

# ===========================================================
# task01_web_logs.sh - анализ кодов веб-сервера
# ===========================================================
# Использование:
#	./tasks01_web_logs.sh [access.log]
#
# По умолчанию читает ./access.log
# ===========================================================

export LC_ALL=C.utf8

LOG="${1:-access.log}"

if [ ! -f "$LOG" ]; then
	echo "Ошибка: файл '$LOG' не найден" >&2
	exit 1
fi

echo "=== Анализ логов: $LOG ==="
echo

# ---- 1. awk: извлечь IP и коды состояния
echo "[1] Извлекаем IP и коды состояния → status_codes.txt"
awk '{print $1, $9}' "$LOG" > status_codes.txt
echo "Готово. Cодержимое:"
cat status_codes.txt
echo

# ---- 2. sed: Найти 4хх и заменить на СLIENT_ERROR ----
echo "[2] Ищем 4хх и заменяем на CLIENT_ERROR → errors.log"
sed -E 's/" ([4][0-9]{2}) [0-9]+$/" CLIENT_ERROR \1/' "$LOG" > errors.log
echo "Готово. Содержимое:"
cat errors.log
echo

# ----3. for: для каждого уникального IP - количество запросов ----
echo "[3] Количество запросов по IP из status_codes.txt | sort -u"
UNIQUE_IPS=$(awk '{print $1}' status_codes.txt | sort -u)

for ip in $UNIQUE_IPS; do
	count=$(grep -c "^$ip " status_codes.txt || true)
	echo " $ip: $count запросов"
done

echo
echo "=== Готово ==="

