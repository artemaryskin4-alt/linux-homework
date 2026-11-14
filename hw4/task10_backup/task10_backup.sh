#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# ============================================================
#  task10_backup.sh — резервное копирование по дням
# ============================================================
#  Использование:
#     ./task10_backup.sh
# ============================================================

BACKUP_DIR="backup"
ALL_BACKUPS="all_backups"
DAYS=7

echo "=== Резервное копирование по дням ==="
echo

# Защита от повторного запуска
if [ -d "$BACKUP_DIR" ] || [ -d "$ALL_BACKUPS" ]; then
    echo "Ошибка: '$BACKUP_DIR' или '$ALL_BACKUPS' уже существует" >&2
    echo "Удалите их или запустите в чистой директории." >&2
    exit 1
fi

# ---- Шаг 1: создать backup/ ----
mkdir -p "$BACKUP_DIR"
echo "[1] Создана директория: $BACKUP_DIR"
echo

# ---- Шаг 2 + 3: цикл — 7 директорий с info.txt ----
echo "[2] Создаём $DAYS директорий с info.txt:"

for i in $(seq 1 "$DAYS"); do
    day_dir="$BACKUP_DIR/day_$i"
    mkdir -p "$day_dir"
    echo "Резервная копия за день $i" > "$day_dir/info.txt"
    echo "  Создано: $day_dir/info.txt"
done
echo

# ---- Шаг 4: for — копируем в all_backups/ ----
echo "[3] Копируем info.txt в $ALL_BACKUPS/:"
mkdir -p "$ALL_BACKUPS"

for i in $(seq 1 "$DAYS"); do
    src="$BACKUP_DIR/day_$i/info.txt"
    dst="$ALL_BACKUPS/info_day_$i.txt"
    cp "$src" "$dst"
    echo "  $src → $dst"
done
echo

# ---- Шаг 5: вывести содержимое all_backups ----
echo "[4] Содержимое $ALL_BACKUPS:"
ls -1 "$ALL_BACKUPS"
echo

echo "[5] Содержимое файлов:"
for f in "$ALL_BACKUPS"/info_day_*.txt; do
    echo "--- $f ---"
    cat "$f"
done

echo
echo "=== Готово ==="
