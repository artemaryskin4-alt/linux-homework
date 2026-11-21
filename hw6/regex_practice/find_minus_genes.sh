#!/usr/bin/env bash
# find_minus_genes.sh — гены на минус-цепи, название длиннее 3 букв,
# и первая буква названия — не A, Z, H (в любом регистре).
# Использование:
#   ./find_minus_genes.sh genes.gff            — фильтр по цепи '-'
#   ./find_minus_genes.sh genes.gff --both     — по обеим цепям (для сравнения)

if [ $# -lt 1 ]; then
  echo "Ой, забыли указать GFF-файл!" >&2
  echo "Пожалуйста, запустите так: $0 <файл.gff> [--both]" >&2
  echo "  Пример: $0 genes.gff          # только минус-цепь" >&2
  echo "  Пример: $0 genes.gff --both   # показать гены с обеих цепей" >&2
  exit 1
fi

GFF="$1"
MODE="${2:---minus}"

if [ ! -f "$GFF" ]; then
  echo "Ошибка: файл '$GFF' не найден. Проверьте путь." >&2
  exit 1
fi

extract_genes() {
    awk -F'[ \t]+' -v strand="$1" '
    $0 !~ /^#/ && $3 == "gene" && $7 == strand {
      if (match($9, /(Name|gene)=[^;]+/)) {
        val = substr($9, RSTART)
        sub(/^[A-Za-z_]+=/, "", val)
        sub(/;$/, "", val)
        if (length(val) > 3 && val !~ /^[AZH]/) {
          print $1, $4, $5, val, $7
        }
      }
    }' "$GFF"
}

echo "=== Отбор: цепь '-', длина названия > 3, имя не начинается с A/Z/H ==="
if [ "$MODE" = "--both" ]; then
  echo "--- Плюс-цепь (для сравнения) ---"
  extract_genes "+"
  echo "--- Минус-цепь (по заданию) ---"
fi
extract_genes "-"
