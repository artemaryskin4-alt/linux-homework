#1/bin/bash

set -euo pipefail

export LC_ALL=C.utf8

# =======================================
# task04_config.sh - трансформация config.json
# =======================================
# Использование:
#	./task04_config.sh [config.json]
#
# По умолчанию читает ./config.json
# =======================================

CONFIG="${1:-config.json}"

if [[ ! -f "$CONFIG" ]]; then
	echo "Ошибка: файл '$CONFIG' не найден" >&2
	exit 1
fi

echo "=== Трансформация конфига: $CONFIG ==="
echo

# ---- ШАГ 1: sed - JSON -> key=value -----
echo "[1] sed: JSON -> key=value"
sed -e 's/[{}]//g' \
    -e 's/"//g' \
    -e 's/,\s*/\n/g' \
    -e 's/\s*:\s*/=/g' \
    -e 's/^[[:space:]]*//' \
    -e 's/[[:space:]]*$//' \
    "$CONFIG" | grep -v '^$' > /tmp/config_step1.txt
cat /tmp/config_step1.txt
echo

# ---- Шаг 2: awk - префикс CONF_ -----
echo "[2] awk: добавляем префикс CONF_"
awk '{ print "CONF_" $0 }' /tmp/config_step1.txt > /tmp/config_step2.txt

cat /tmp/config_step2.txt
echo

# ---- ШАГ 3: for -----
echo "[3] for: экспортируем переменные"

# Читаем в массив
mapfile -t lines < /tmp/config_step2.txt

# for по массиву
for line in "${lines[@]}"; do
	[ -z "$line" ] && continue
	key="${line%%=*}"
	value="${line#*=}"
	export "$key=$value"
	echo " export $key=$value"
done

echo
echo "Проверка:"
echo "  CONF host = ${CONF_host:-<не задано>}"
echo "	CONF_port = ${CONF_port:-<не задано>}"
echo "	CONF_debug = ${CONF_debug:-<не задано>}"

rm -f /tmp/config_step.txt /tmp/config_step2.txt
echo
echo "=== Готово ==="

