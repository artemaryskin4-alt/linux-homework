#!/bin/bash
set -euo pipefail

# ============================================================
#  countdown.sh — обратный отсчёт с анимацией
# ============================================================
#  Использование:
#     ./countdown.sh [секунды] [режим]
#
#  Аргументы:
#     секунды   — с чего начинать (по умолчанию 10)
#     режим     — grow | shrink | fill (по умолчанию grow)
#
#  Переменные окружения (опционально):
#     WIDTH=20      ширина шкалы в символах
#     DELAY=1       задержка между шагами в секундах
#     SYMBOL=*      символ для анимации
# ============================================================

WIDTH="${WIDTH:-20}"
DELAY="${DELAY:-1}"
SYMBOL="${SYMBOL:-*}"

# ---- Справка ----
if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
Использование: $0 [секунды] [режим]

Аргументы:
  секунды   — с чего начинать (по умолчанию 10)
  режим     — grow | shrink | fill (по умолчанию grow)
              grow   — звёздочек становится больше
              shrink — звёздочек становится меньше
              fill   — шкала заполняется до половины и обратно

Переменные окружения:
  WIDTH=20      ширина шкалы (по умолчанию 20)
  DELAY=1       задержка между шагами (по умолчанию 1)
  SYMBOL=*      символ анимации

Примеры:
  $0
  $0 5
  $0 10 shrink
  WIDTH=30 SYMBOL=# \$0 5
  DELAY=0.2 \$0 20
EOF
    exit 0
fi

SECONDS_ARG="${1:-10}"
MODE="${2:-grow}"

# ---- Проверки ----
if ! [[ "$SECONDS_ARG" =~ ^[0-9]+$ ]] || [ "$SECONDS_ARG" -lt 1 ]; then
    echo "Ошибка: количество секунд должно быть положительным числом" >&2
    exit 1
fi

if ! [[ "$WIDTH" =~ ^[0-9]+$ ]] || [ "$WIDTH" -lt 1 ]; then
    echo "Ошибка: WIDTH должно быть положительным числом" >&2
    exit 1
fi

case "$MODE" in
    grow|shrink|fill) ;;
    *) echo "Ошибка: режим должен быть grow|shrink|fill" >&2; exit 1 ;;
esac

# ---- Цвета (если терминал поддерживает) ----
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    GREEN=""; RED=""; YELLOW=""; NC=""
fi

# ---- Функция: нарисовать шкалу ----
# $1 — сколько звёздочек
# $2 — общая ширина
draw_bar() {
    local filled=$1
    local total=$2
    local empty=$((total - filled))
    printf "["
    printf "%0.s$SYMBOL" $(seq 1 "$filled") 2>/dev/null
    printf "%0.s." $(seq 1 "$empty") 2>/dev/null
    printf "]"
}

# ---- Шапка ----
echo -e "${YELLOW}Обратный отсчёт: ${SECONDS_ARG} сек (режим: ${MODE}, ширина: ${WIDTH})${NC}"
echo

# ---- Основной цикл ----
for ((i = SECONDS_ARG; i >= 0; i--)); do
    # Считаем, сколько звёздочек показать
    case "$MODE" in
        grow)
            # чем меньше секунд, тем больше звёздочек
            filled=$(( WIDTH * (SECONDS_ARG - i) / SECONDS_ARG ))
            ;;
        shrink)
            # чем меньше секунд, тем меньше звёздочек
            filled=$(( WIDTH * i / SECONDS_ARG ))
            ;;
        fill)
            # туда и обратно: 0..WIDTH..0
            half=$(( SECONDS_ARG / 2 ))
            if [ "$i" -ge "$half" ]; then
                # первая половина: растёт
                filled=$(( WIDTH * (SECONDS_ARG - i) / half ))
            else
                # вторая половина: убывает
                filled=$(( WIDTH * i / half ))
            fi
            ;;
    esac

    # Цвет шкалы: красный к концу
    if [ "$i" -le 3 ]; then
        color="$RED"
    else
        color="$GREEN"
    fi

    # \r возвращает каретку в начало строки — перерисовываем поверх
    printf "\r${color}"
    draw_bar "$filled" "$WIDTH"
    printf " %2d сек${NC}  " "$i"

    # Последний шаг — не ждём
    if [ "$i" -gt 0 ]; then
        sleep "$DELAY"
    fi
done

# ---- Финал ----
echo
echo
echo -e "${RED}Время вышло!${NC}"


