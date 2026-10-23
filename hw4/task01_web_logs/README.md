markdown
# Задание 1: анализ логов веб-сервера

## Что делает
Скрипт `task01_web_logs.sh` анализирует `access.log` в Common Log Format:

1. Извлекает IP-адреса и коды состояния через `awk` → `status_codes.txt`.
2. Находит строки с ошибками 4xx, заменяет код на `CLIENT_ERROR` через `sed` → `errors.log`.
3. Считает количество запросов по каждому уникальному IP через `for` + `grep` + `wc -l`.

## Запуск
    ./task01_web_logs.sh access.log

## Файлы
- `access.log` — тестовые данные
- `task01_web_logs.sh` — скрипт
- `status_codes.txt` — результат пункта 1
- `errors.log` — результат пункта 2
