#!/bin/bash
set -euo pipefail
# ============================================================
#  task02_products.sh — обработка ценового каталога
# ============================================================
#  Использование:
#     ./task02_products.sh [products.csv]
#
#  По умолчанию читает ./products.csv
# ============================================================

export LC_ALL=C.utf8
CSV="${1:-products.csv}"
if [ ! -f "$CSV" ]; then
	echo "Ошибка: файл "$CSV" не найден" >&2
	exit 1
fi

echo "=== Обработка каталога ==="
echo

# ----- 1. awk: общая стоимость по категориям (Price * Stock), по убыванию -----
echo "[1] Общая стоимость товаров по категориям (Price * Stock):"
awk -F',' '
	NR == 1 { next }
	{
		category=$3
		price=$4 + 0
		stock=$5 + 0
		total[category] += price * stock
	}
	END {
	    for (cat in total) {
		printf "%s\t%.2f\n", cat, total[cat]
	    }
	}
   ' "$CSV" | sort -t$'\t' -k2 -rn | awk -F'\t' '{
	printf "  %-15s %10.2f\n", $1, $2
   }'
   echo

#2 ---- 2. sed: удалить товары с Stock = 0 → available_products.csv ----
echo "[2] Удаляем товары с Stock = 0 → available_products.csv"

#Сохраняем заголовок
head -1 "$CSV" > available_products.csv

#Фильтруем: оставляем строки, где последнее поле (Stock) не равно 0
#Используем sed для удаления строк, где Stock = 0 в конце
sed -E '/,[0-9]+\.?[0-9]*,0$/d' "$CSV" | tail -n +2 >> available_products.csv

echo "Готово. Содержимое:"
cat available_products.csv
echo

# ----- 3. while: читает available_products.csv, выводит Name, где Price > 100 ----
echo "[3] Товары с ценой > 100:"

#Пропускаем заголовок, читаем построчно
tail -n +2 available_products.csv | while IFS=',' read -r id name category price stock; do
	result=$(echo "$id,$name,$category,$price,$stock" | awk -F',' '$4 + 0 > 100 {print $2}')
	if [ -n "$result" ]; then
		echo "  $result ($price)"
	fi
done

echo
echo "=== Готово ==="

