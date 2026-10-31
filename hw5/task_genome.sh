#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# ============================================================
#  task_genome.sh — извлечение границ протеин-кодирующих генов
# ============================================================
#  Использование:
#     ./task_genome.sh [входной.gff3] [выходной.tsv]
# ============================================================

# Директория скрипта (независимо от места запуска)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GFF="${1:-$SCRIPT_DIR/data/gencode.v41.basic.annotation.gff3}"
OUTDIR="$SCRIPT_DIR/terminal_task/results"
OUT="${2:-$OUTDIR/result.tsv}"

# Проверки
if [ ! -f "$GFF" ]; then
    echo "Ошибка: файл '$GFF' не найден" >&2
    echo "Скачайте и распакуйте аннотацию GENCODE в data/" >&2
    exit 1
fi

mkdir -p "$OUTDIR"
echo "=== Извлечение границ генов ==="
echo "Вход:  $GFF"
echo "Выход: $OUT"
echo

# ---- Основная обработка через awk ----
awk -F'\t' '
    /^#/ { next }
    NF < 9 { next }
    $3 != "gene" { next }
    $9 !~ /gene_type=unprocessed_pseudogene/ { next }

    {
        gene_name = ""
        n = split($9, attrs, ";")
        for (i = 1; i <= n; i++) {
            if (attrs[i] ~ /^gene_name=/) {
                gene_name = attrs[i]
                sub(/^gene_name=/, "", gene_name)
                break
            }
        }
        if (gene_name == "") next

        chr    = $1
        start  = $4 + 0
        end    = $5 + 0
        strand = $7

        if (strand == "+") {
            new_start = start
            new_end   = start + 1
        } else if (strand == "-") {
            new_start = end
            new_end   = end + 1
        } else {
            next
        }

        printf "%s\t%d\t%d\t%s\t%s\n", chr, new_start, new_end, strand, gene_name
    }
' "$GFF" > "$OUT"

lines=$(wc -l < "$OUT")
echo "Готово."
echo "Записано строк: $lines"
echo "Файл: $OUT"
echo
echo "Первые 5 строк результата:"
head -5 "$OUT"
