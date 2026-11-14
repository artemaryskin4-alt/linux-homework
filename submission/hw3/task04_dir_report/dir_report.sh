#!/bin/bash
set -euo pipefail

# ============================================================
#  dir_report.sh — отчёт о файлах в директории
# ============================================================
#  Использование:
#     ./dir_report.sh [-r] [директория]
#
#  Опции:
#     -r    рекурсивно обходить подпапки
#
#  Переменные окружения (опционально):
#     TOP_N=10    показать топ-N самых больших файлов (0 = не показывать)
# ============================================================

# ---- Значения по умолчанию ----

TARGET_DIR="."
RECURSIVE=0
TOP_N="${TOP_N:-5}"

# ---- Справка ----
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
Использование: $0 [-r] [директория]

Опции:
  -r    рекурсивно обходить подпапки

Переменные окружения:
  TOP_N=10    сколько самых больших файлов показать (0 = отключить)

Примеры:
  $0
  $0 ~/linux-hw3
  $0 -r /var/log
  TOP_N=0 $0 -r ~/docs
EOF
    exit 0
fi

# ---- Разбор флага -r ----
if [ "${1:-}" = "-r" ]; then
    RECURSIVE=1
    shift
fi

# ---- Директория (первый оставшийся аргумент) ----
TARGET_DIR="${1:-.}"

# ---- Проверки ----
if [ ! -e "$TARGET_DIR" ]; then
    echo "Ошибка: '$TARGET_DIR' не существует" >&2
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "Ошибка: '$TARGET_DIR' — не директория" >&2
    exit 1
fi

if [ ! -r "$TARGET_DIR" ]; then
    echo "Ошибка: нет прав на чтение '$TARGET_DIR'" >&2
    exit 1
fi

# ---- Определяем глубину обхода ----
if [ "$RECURSIVE" -eq 1 ]; then
    MAXDEPTH=""
    MODE="рекурсивно"
else
    MAXDEPTH="-maxdepth 1"
    MODE="только текущая папка"
fi

# ---- Шапка ----
echo "Отчёт о файлах в директории: $TARGET_DIR"
echo "Режим: $MODE"
echo "Дата: $(date '+%Y-%m-%d %H:%M:%S')"
echo "============================================================"

# ---- Собираем данные через find + awk ----
# find печатает: <размер_в_байтах> <путь>
# awk агрегирует: по расширению — count и сумма байт
find "$TARGET_DIR" $MAXDEPTH -type f -printf '%s %p\n' 2>/dev/null \
    | awk '
        {
            size = $1
            path = $0
            sub(/^[0-9]+ /, "", path)     # убираем размер из строки, остаётся путь

            # Извлекаем расширение файла
            n = split(path, parts, "/")
            name = parts[n]
            if (name ~ /\./) {
                m = split(name, nameparts, ".")
                ext = nameparts[m]
                ext = tolower(ext)
            } else {
                ext = "(без расширения)"
            }

            count[ext]++
            total[ext] += size
            grand_total += size
            files_total++
        }
        END {
            # Выводим в формате: ext<TAB>count<TAB>total
            for (e in count) {
                printf "%s\t%d\t%d\n", e, count[e], total[e]
            }
            # Отдельной строкой — итого
            printf "__TOTAL__\t%d\t%d\n", files_total, grand_total
        }
    ' \
    | sort -t$'\t' -k3 -rn \
    | awk -F'\t' '
        BEGIN {
            printf "%-20s %10s %15s\n", "Тип", "Файлов", "Размер"
            printf "%-20s %10s %15s\n", "--------------------", "----------", "---------------"
        }
        $1 == "__TOTAL__" {
            total_files = $2
            total_size  = $3
            next
        }
        {
            printf "%-20s %10d %15s\n", $1, $2, human($3)
        }
        END {
            printf "%-20s %10s %15s\n", "--------------------", "----------", "---------------"
            printf "%-20s %10d %15s\n", "ИТОГО", total_files, human(total_size)
        }

        function human(bytes,    units, i) {
            split("Б КБ МБ ГБ ТБ", units, " ")
            i = 1
            while (bytes >= 1024 && i < 5) {
                bytes /= 1024
                i++
            }
            if (i == 1) return sprintf("%d %s", bytes, units[i])
            return sprintf("%.1f %s", bytes, units[i])
        }
    '

# ---- Топ-N самых больших файлов ----
if [ "$TOP_N" -gt 0 ]; then
    echo
    echo "Топ-$TOP_N самых больших файлов:"
    echo "------------------------------------------------------------"
    find "$TARGET_DIR" $MAXDEPTH -type f -printf '%s\t%p\n' 2>/dev/null \
        | sort -rn \
        | head -n "$TOP_N" \
        | awk -F'\t' '
            function human(bytes,    units, i) {
                split("Б КБ МБ ГБ ТБ", units, " ")
                i = 1
                while (bytes >= 1024 && i < 5) {
                    bytes /= 1024
                    i++
                }
                if (i == 1) return sprintf("%d %s", bytes, units[i])
                return sprintf("%.1f %s", bytes, units[i])
            }
            { printf "%3d. %10s  %s\n", NR, human($1), $2 }
        '
fi

echo "============================================================"
