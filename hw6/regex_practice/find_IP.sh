#!/usr/bin/env bash
# find_IP.sh — поиск IP активных пользователей (IPv4 и IPv6),
# с опциональным разбором истории подключений из логов.
#
# Использование:
#   ./find_IP.sh                — реальный запуск (who)
#   ./find_IP.sh who_test.txt   — тестовый режим
#   ./find_IP.sh --logs         — история подключений из auth.log/secure
#   ./find_IP.sh --logs мой.log — история из своего файла логов

get_input() {
  if [ -n "$1" ]; then
    cat "$1"
  else
    who -u 2>/dev/null
  fi
}

# Регулярка: IPv4 или IPv6 (упрощённая, но достаточная для who/логов)
IP_RE='[0-9a-fA-F:]*::[0-9a-fA-F:]+|([0-9a-fA-F]{1,4}:){2,7}[0-9a-fA-F]{1,4}|([0-9]{1,3}\.){3}[0-9]{1,3}'

# Функция: вытянуть первый IP из строки (IPv4 в приоритете)
extract_ip() {
  echo "$1" | sed -E 's/^[A-Z][a-z]{2}[ ]+[0-9]{1,2}[ ]+[0-9]{2}:[0-9]{2}:[0-9]{2}[ ]+//' \
    | grep -oE "$IP_RE" | head -n1
}

# Функция: связки "пользователь — IP" для потока ввода
user_ip_pairs() {
  while IFS= read -r line; do
    user=$(echo "$line" | awk '{print $1}')
    ip=$(extract_ip "$line")
    [ -n "$ip" ] && echo "$user — $ip"
  done
}

if [ "${1:-}" = "--logs" ]; then
  # ─── Режим разбора логов ───
  # Ищем файл лога: аргумент после --logs, иначе типовые пути
  LOG_FILE="${2:-}"
  if [ -z "$LOG_FILE" ]; then
    for f in /var/log/auth.log /var/log/secure; do
      if [ -f "$f" ]; then
        LOG_FILE="$f"
        break
      fi
    done
  fi
  if [ -z "$LOG_FILE" ] || [ ! -f "$LOG_FILE" ]; then
    echo "Лог не найден. Передайте файл: $0 --logs /путь/к/log" >&2
    exit 1
  fi

  echo "=== История подключений: $LOG_FILE ==="
  # Ищем записи о Successful open / Accepted для SSH
  grep -E 'Accepted|session opened' "$LOG_FILE" 2>/dev/null | while IFS= read -r line; do
    # Пользователь: после "for" или в "session opened for user X"
    user=$(echo "$line" | grep -oE 'Accepted [a-z]+ for [a-zA-Z0-9_.-]+' | awk '{print $NF}')
    [ -z "$user" ] && user=$(echo "$line" | sed -nE 's/.*session opened for user ([^ ]+).*/\1/p')
    ip=$(extract_ip "$line")
    if [ -n "$user" ] && [ -n "$ip" ]; then
      echo "$user — $ip"
    fi
  done | sort | uniq -c | sort -rn | awk '{printf "%5s  %-15s %s\n", $1, $2, $3}'

  echo
  echo "=== Уникальные IP за всё время ==="
  grep -E 'Accepted' "$LOG_FILE" 2>/dev/null | grep -oE "$IP_RE" | sort -u
  exit 0
fi

# ─── Обычный режим: активные сессии ───
echo "=== IP из активных сессий ==="
get_input "$1" | grep -oE "$IP_RE" | sort -u

echo
echo "=== Пользователи и их IP ==="
get_input "$1" | user_ip_pairs

