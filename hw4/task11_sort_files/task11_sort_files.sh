#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# ============================================================
#  task11_sort_files.sh — сортировка файлов по расширениям
# ============================================================
#  Использование:
#     ./task11_sort_files.sh
# ============================================================

echo "=== Сортировка файлов по расширениям ==="
echo

# ---- Шаг 0: создать тестовые файлы ----
echo "[0] Создаём тестовые файлы:"
for f in image1.jpg image2.png doc1.txt doc2.pdf script.sh archive.tar.gz; do
    touch "$f"
    echo "  Создан: $f"
done
echo

# ---- Шаг 1: создать директории ----
echo "[1] Создаём директории:"
for dir in images documents scripts archives; do
    mkdir -p "$dir"
    echo "  Создана: $dir/"
done
echo

# ---- Шаг 2-4: for + case — перемещение ----
echo "[2] Перемещаем файлы по расширениям:"

# Отключаем glob, если файлов нет (не критично, но защищает)
shopt -s nullglob

for file in *; do
    # Пропускаем директории
    [ -f "$file" ] || continue

    # Пропускаем сам скрипт
    [ "$file" = "task11_sort_files.sh" ] && continue

    # Определяем расширение через case
    case "$file" in
        *.tar.gz)
            target="archives"
            ;;
        *.jpg|*.png)
            target="images"
            ;;
        *.txt|*.pdf)
            target="documents"
            ;;
        *.sh)
            target="scripts"
            ;;
        *)
            # Неизвестное расширение — пропускаем
            echo "  ⚠ Пропуск: $file (неизвестное расширение)"
            continue
            ;;
    esac

    mv "$file" "$target/"
    echo "  $file → $target/"
done

shopt -u nullglob
echo

# ---- Шаг 5: ls -R ----
echo "[3] Структура директорий:"
ls -R images documents scripts archives

echo
echo "=== Готово ==="
