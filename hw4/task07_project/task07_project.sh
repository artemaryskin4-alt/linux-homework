#!/bin/bash
set -euo pipefail

export LC_ALL=C.utf8

# =======================================
# task07_project.sh [имя проекта]
# =======================================
# Использование:
#	./task07_project.sh [имя_проекта]
# По умолчанию cоздает ./my_project
# ==========================================

PROJECT="${1:-my_project}"

# Защита: не перезаписывать существующий
if [[ -d "$PROJECT" ]]; then
	echo "Ошибка: директория '$PROJECT' уже существует" >&2
	exit 1
fi

echo "=== Создание структуры проекта: $PROJECT ==="
echo

# ---- ШАГ 1: корневая директория
mkdir -p "$PROJECT"
echo "Создана директория: $PROJECT"

# ---- ШАГ 2 + 3 - создаем поддиректории и их подпапки ------
#Создаем поддиректории
SUB_DIRS=(src docs tests build)

#Cоздаем подпапки
NESTED=(images scripts data)

for sub in "${SUB_DIRS[@]}"; do
	mkdir -p "$PROJECT/$sub"
	echo "Создана директория: $PROJECT/$sub"
	
	for inner in "${NESTED[@]}"; do
		mkdir -p "$PROJECT/$sub/$inner"
		echo "Создана директория: $PROJECT/$sub/$inner"
	done
done

# ---- ШАГ 4: for - вывод всех директорий -----
echo
echo "[4] Список всех директорий (for + find):"
mapfile -t dirs < <(find "$PROJECT" -type d | sort)
for dir in "${dirs[@]}"; do
	echo "  Создана директория: $dir"
done

# Шаг 5: README
touch "$PROJECT/README.md"
echo
echo "Создан файл: $PROJECT/README.md"

echo 
echo "=== Готово ==="


