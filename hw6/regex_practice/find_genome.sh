#!/usr/bin/env bash
# find_genome.sh — поиск файлов с genome и/или GCA в имени + статистика.
# Режимы:
#   ./find_genome.sh /path        — genome ИЛИ GCA (по умолчанию)
#   ./find_genome.sh /path --and — genome И GCA
#   ./find_genome.sh /path --each — отдельные списки + статистика

if [ $# -lt 1 ]; then
  echo "Использование: $0 <директория> [--and | --each]" >&2
  exit 1
fi

DIR="$1"
MODE="${2:---or}"

if [ ! -d "$DIR" ]; then
  echo "Директория не найдена: $DIR" >&2
  exit 1
fi

# Функция: посчитать кол-во и общий размер файлов из потока find
stats_from_find() {
  local count=0 size=0
  while IFS= read -r f; do
    ((count++))
    # stat -c '%s' работает на Linux; на macOS нужен другой синтаксис
    local s
    s=$(stat -c '%s' "$f" 2>/dev/null) || s=0
    ((size += s))
  done
  printf "%d файлов, суммарно %d байт\n" "$count" "$size"
}

case "$MODE" in
  --and)
    echo "=== Файлы с genome И GCA в имени ==="
    files=$(find "$DIR" -type f -iname '*genome*' -iname '*GCA*')
    printf '%s\n' "$files"
    if [ -n "$files" ]; then
      printf '%s\n' "$files" | stats_from_find
    else
      echo "0 файлов"
    fi
    ;;
  --each)
    echo "=== Файлы с genome ==="
    files_genome=$(find "$DIR" -type f -iname '*genome*')
    printf '%s\n' "$files_genome"
    if [ -n "$files_genome" ]; then
      printf '%s\n' "$files_genome" | stats_from_find
    else
      echo "0 файлов"
    fi

    echo
    echo "=== Файлы с GCA ==="
    files_gca=$(find "$DIR" -type f -iname '*GCA*')
    printf '%s\n' "$files_gca"
    if [ -n "$files_gca" ]; then
      printf '%s\n' "$files_gca" | stats_from_find
    else
      echo "0 файлов"
    fi
    ;;
  *)
    echo "=== Файлы с genome ИЛИ GCA в имени ==="
    find "$DIR" -type f \( -iname '*genome*' -o -iname '*GCA*' \) | while IFS= read -r f; do
      echo "$f"
    done
    # Статистика для режима OR
    find "$DIR" -type f \( -iname '*genome*' -o -iname '*GCA*' \) | stats_from_find
    ;;
esac

