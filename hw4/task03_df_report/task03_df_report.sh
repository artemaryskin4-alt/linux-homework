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
echo "[1] df -h:  Форматируем df -h (Filesystem + Use%"
df -h | awk 'NR > 1 { print $1, $5 }' > /tmp/df_step1.txt
cat /tmp/df_step1.txt
echo


# ---- Шаг 2: sed - убрать %, заменить dev на device ----
echo "[2] Убираем % и заменяем dev на device: "
sed -e  's/%//g' -e 's|/dev/|/device/|g' /tmp/df_step1.txt > /tmp/df_step2.txt
cat /tmp/df_step2.txt
echo

# ---- Шаг 3: for - предупреждение для ФС с > 80% ----
echo "[3] Предупреждения для ФС > 80%:"
found=0
mapfile -t lines < /tmp/df_step2.txt

for line in "${lines[@]}"; do
    [ -z "$line" ] && continue
    usage=$(echo "$line" | awk '{print $NF}')
    if [[ "$usage" =~ ^[0-9]+$ ]] && [ "$usage" -gt 80 ]; then
        fs=$(echo "$line" | awk '{print $1}')
        echo "  ⚠  $fs использует $usage%"
        found=1
    fi
done


if [ "$found" -eq 0 ]; then
	echo " Всё в порядке."
fi

rm -f /tmp/df_step1.txt /tmp/df_step2.txt
echo
echo "=== Готово ==="
