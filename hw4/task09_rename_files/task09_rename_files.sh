#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# ============================================
# task09_rename_files - переименование файлов
# ============================================
# Использование:
#	./task09_rename_files
# ===========================================

RENAMED_DIR="renamed"

echo "=== Переименование файлов ===="
echo

# ----- Проверка на существование директории ------
if [[ -d "$RENAMED_DIR" ]]; then
	echo "Директория $RENAMED_DIR уже существует" >&2
	exit 1
fi


# ----- Шаг 0. Cоздание 5 файлов document1.txt ... document5.txt
echo "[0] Cоздаём 5 файлов document1.txt ... document5.txt"
for i in {1..5}; do
	touch "document${i}.txt"
	echo "	Создан: document${i}.txt"
done
echo

# ----- Шаг 1:  создать директорию renamed ----
mkdir -p "$RENAMED_DIR"
echo "[1] Создана директория: $RENAMED_DIR"
echo

# ----- Шаг 2: while - читаем список файлов -----
echo "[2] Переименовываем и перемещаем:"

#ls document*.txt | while read -r file
# ВАЖНО: while в pipe работает в подоболочке - не критично, нам важен только вывод
ls document*.txt 2>/dev/null | while IFS= read -r file; do
	# Извлекаем номер и новое имя
	new_name="${file/document/file}" #document3.txt -> file3.txt
	target="$RENAMED_DIR/$new_name"
	
	# Перемещаем
	mv "$file" "$target"
	echo "	$file -> $target"
done

echo

#Шаг 3: вывести список в renamed -----
echo "[3] Cодержимое $RENAMED_DIR:"
ls -1 "$RENAMED_DIR"

echo
echo "=== Готово ==="

