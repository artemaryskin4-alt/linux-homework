#!/bin/bash
set -euo pipefail   # Защита от типичных ошибок

# ---- Значения по умолчанию ----
SRC_DIR="."
RECURSIVE=0            # 0 = без вложенных папок, 1 = рекурсивно
USE_TIME=0             # 0 = только дата, 1 = дата+время

# ---- Значения по умолчанию ----
SRC_DIR="."
RECURSIVE=0            # 0 = без вложенных папок, 1 = рекурсивно
USE_TIME=0             # 0 = только дата, 1 = дата+время

# ---- Разбор аргументов-флагов
while getopts "rt" opt; do
    case "$opt" in
        r) RECURSIVE=1 ;;
        t) USE_TIME=1 ;;
        *) echo "Использование: $0 [-r] [-t] [директория]"; exit 1 ;;
    esac
done
shift $((OPTIND - 1))   # убираем флаги из $@, чтобы $1 стал директорией

# Первый оставшийся аргумент — директория (если есть)
SRC_DIR="${1:-.}"

# ---- Формирование даты (улучшение №3) ----
if [ "$USE_TIME" -eq 1 ]; then
    DATE=$(date +%Y-%m-%d_%H-%M-%S)
else
    DATE=$(date +%Y-%m-%d)
fi

BACKUP_DIR="$SRC_DIR/backup"


# ---- Проверки ----
if [ ! -d "$SRC_DIR" ]; then
    echo "Ошибка: директория '$SRC_DIR' не существует"
    exit 1
fi

if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
    echo "Создана папка для бэкапов: $BACKUP_DIR"
fi

echo "Источник: $SRC_DIR"
echo "Дата: $DATE"
[ "$RECURSIVE" -eq 1 ] && echo "Режим: рекурсивный" || echo "Режим: только текущая папка"
echo "----------------------------------------"

count=0
skipped=0

# ---- Выбор способа обхода файлов
if [ "$RECURSIVE" -eq 1 ]; then
    FILES=$(find "$SRC_DIR" -type f -name '*.txt' -not -path "$BACKUP_DIR/*")
else
    FILES=$(find "$SRC_DIR" -maxdepth 1 -type f -name '*.txt' -not -path "$BACKUP_DIR/*")
fi

# Цикл по найденным файлам (безопасный — работает и с пробелами)
while IFS= read -r file; do
    [ -z "$file" ] && continue

    filename=$(basename "$file")
    base="${filename%.txt}"
    backup_name="${base}_${DATE}.txt"
    target="$BACKUP_DIR/$backup_name"

    # ---- Улучшение №5: не перезаписываем существующие копии ----
    if [ -e "$target" ]; then
        echo "Уже есть: $backup_name — пропускаю"
        skipped=$((skipped + 1))
        continue
    fi

    cp "$file" "$target"
    echo "✓ $filename → backup/$backup_name"
    count=$((count + 1))
done <<< "$FILES"

echo "----------------------------------------"
echo "Создано копий: $count, пропущено: $skipped"
