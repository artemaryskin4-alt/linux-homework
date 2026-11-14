#!/bin/bash
set -euo pipefail
export LC_ALL=C.utf8


# ============================================================
#  students_filter.sh — студенты с оценкой выше порога по предметам
# ============================================================
#  Использование:
#     ./students_filter.sh <файл> <порог>
#
#  Переменные окружения (опционально):
#     SEP=,          разделитель полей (по умолчанию запятая)
#     INCLUDE_EQUAL=1   включать оценку, равную порогу (>= вместо >)
#     SORT_BY=grade    сортировка внутри предмета: grade (по умолч.) или name
# ============================================================

# ---- Справка ----
if [ $# -lt 2 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    cat <<EOF
Использование: $0 <файл> <порог>

Аргументы:
  файл    — CSV/TSV-файл с колонками: ФИО, оценка, предмет
  порог   — минимальная оценка (число, например 4)

Переменные окружения:
  SEP=,             разделитель полей (по умолчанию запятая)
  INCLUDE_EQUAL=1   включать оценку, равную порогу (>= вместо >)
  SORT_BY=name      сортировать по имени, а не по оценке

Примеры:
  $0 grades.csv 4
  $0 grades.csv 4.5
  SEP=$'\t' $0 grades.tsv 4
  INCLUDE_EQUAL=1 $0 grades.csv 4
  SORT_BY=name $0 grades.csv 4
EOF
    exit 0
fi

FILE="$1"
THRESHOLD="$2"
SEP="${SEP:-,}"
INCLUDE_EQUAL="${INCLUDE_EQUAL:-0}"
SORT_BY="${SORT_BY:-grade}"

# ---- Проверки ----
if [ ! -f "$FILE" ]; then
    echo "Ошибка: файл '$FILE' не найден" >&2
    exit 1
fi

if [ ! -s "$FILE" ]; then
    echo "Ошибка: файл '$FILE' пуст" >&2
    exit 1
fi

if ! [[ "$THRESHOLD" =~ ^[0-9]+([.,][0-9]+)?$ ]]; then
    echo "Ошибка: порог '$THRESHOLD' должен быть числом" >&2
    exit 1
fi

# Нормализуем запятую в десятичной дроби в точку (для awk)
THRESHOLD="${THRESHOLD/,/.}"

# ---- Шапка ----
if [ "$INCLUDE_EQUAL" -eq 1 ]; then
    OP_STR=">="
else
    OP_STR=">"
fi

echo "Студенты с оценкой $OP_STR $THRESHOLD по предметам"

echo "Файл: $FILE"
echo "============================================================"

# ---- Основная логика на awk ----
awk -F"$SEP" -v threshold="$THRESHOLD" -v inc="$INCLUDE_EQUAL" -v sort_by="$SORT_BY" '
#Убираем Windows-переводы строк (\r)
{ sub(/\r$/, "") }

# Пропускаем пустые строки и комментарии
    /^[[:space:]]*$/ { next }
    /^[[:space:]]*#/ { next }
# Ожидаем минимум 3 поля
    NF < 3 { next }

    {
        name  = $1
        grade = $2
        subj  = $3

        # Убираем кавычки, если есть
        gsub(/^"|"$/, "", name)
        gsub(/^"|"$/, "", subj)
        gsub(/^"|"$/, "", grade)

	# Нормализуем запятую в оценке
        gsub(/,/, ".", grade)

        # Проверяем, что оценка — число
        if (grade !~ /^[0-9]+(\.[0-9]+)?$/) { next }
	# Условие: > или >=
        if (inc == 1) {
            if (grade + 0 < threshold + 0) next
        } else {
            if (grade + 0 <= threshold + 0) next
        }

	# Сохраняем: subjects[предмет] = список "оценка|имя"
        # Используем разделитель "|" для последующего разбора
        subjects[subj] = subjects[subj] grade "|" name "\n"
        count[subj]++
        total++
    }

    END {
        if (total == 0) {
            print "Нет студентов с оценкой выше порога."
            exit 0
        }

	# Сортируем названия предметов по алфавиту
        n = 0
        for (s in subjects) subj_list[++n] = s

	# Простая сортировка (пузырьком, для надёжности)
        for (i = 1; i <= n; i++) {
            for (j = i + 1; j <= n; j++) {
                if (subj_list[i] > subj_list[j]) {
                    tmp = subj_list[i]
                    subj_list[i] = subj_list[j]
                    subj_list[j] = tmp
                }
            }
        }

	# Выводим по предметам
        for (i = 1; i <= n; i++) {
            s = subj_list[i]
            print ""
            printf "=== %s (%d) ===\n", s, count[s]

	# Разбираем накопленные данные
            # subjects[s] = "grade|name\ngrade|name\n..."
            m = split(subjects[s], lines, "\n")
            delete grades
            delete names
            for (k = 1; k <= m; k++) {
                if (lines[k] == "") continue
                if (split(lines[k], pair, "|") == 2) {
                    grades[k] = pair[1] + 0
                    names[k]  = pair[2]
                }
            }
	
	    # Сортируем внутри предмета
            cnt = m
            for (a = 1; a <= cnt; a++) {
                for (b = a + 1; b <= cnt; b++) {
                    if (lines[a] == "" || lines[b] == "") continue
                    if (sort_by == "name") {
                        if (names[a] > names[b]) {
                            tg = grades[a]; tn = names[a]
                            grades[a] = grades[b]; names[a] = names[b]
                            grades[b] = tg; names[b] = tn
                            tl = lines[a]; lines[a] = lines[b]; lines[b] = tl
                        }
                    } else {
                        if (grades[a] < grades[b]) {
                            tg = grades[a]; tn = names[a]
                            grades[a] = grades[b]; names[a] = names[b]
                            grades[b] = tg; names[b] = tn
                            tl = lines[a]; lines[a] = lines[b]; lines[b] = tl
                        }
                    }
                }
            }
	    
	    # Печатаем
            for (k = 1; k <= cnt; k++) {
                if (lines[k] == "") continue
                printf "  %-30s %s\n", names[k], grades[k]
            }
        }
	
	print ""
        print "============================================================"
        printf "Всего студентов: %d\n", total
    }
' "$FILE"

