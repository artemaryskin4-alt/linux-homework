#!/bin/bash
set -euo pipefail

# ===================================================
# task03_df_report.sh - генератор отчетов из df -h
# ===================================================
# Использование:
#	./task03_df_report.sh
# Показывает использование дисков, предупреждает при > 80%
# ===================================================

export LC_ALL=C.utf8
echo "=== Генератор отчётов из df -h ==="
echo

# ---- Шаг 1: awk - только Filesystem и Use%, без заголовков -----
echo "[1] Форматируем df -h (Filesystem + Use%"

# df -h | awk 'NR > 1 {print $1, $5}'
# NR > 1 - пропускаем заголовок
# $1 - Filesystem, $5-Use%
df -h | awk 'NR > 1 { print $1, $5 }' > /tmp/df_step1.txt

cat /tmp/df_step1.txt
echo

# ---- Шаг 2: sed - убрать %, заменить dev на device ----
echo "[2] Убираем % и заменяем dev на device: "

sed -e  's/%//g' -e 's|/dev/|/device/|g' /tmp/df_step1.txt | tee /tmp/df_step2.txt

# ---- Шаг 3: for - предупреждение для ФС с > 80% ----
echo "[3] Предупреждение для ФС > 80%:"
warning=0
for line in $(cat /tmp/df_step2.txt); do
	fs=$(echo "$line" | awk '{print $1}')
	usage=$(echo "$line" | awk '{print $2}')
	if [ "$usage" -gt 80 ]; then
		echo "Внимание! $fs использует $usage%"
		warning=1
	fi
done
[ "$warning" -eq 0 ] && echo " Всё в порядке."

rm -f /tmp/df_step1.txt /tmp/df_step2.txt
echo
echo "=== Готово ==="
