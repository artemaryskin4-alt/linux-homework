# Задание 4: трансформация config.json

## Что делает
Скрипт `task04_config.sh` преобразует JSON-конфиг в переменные среды:

1. `sed` — JSON → `key=value` (убирает `{}`, `"`, заменяет `:` на `=`, разбивает по запятым).
2. `awk` — добавляет префикс `CONF_` к каждой строке.
3. `for` — читает итоговый файл и экспортирует каждую строку как переменную среды.

## Запуск
    ./task04_config.sh config.json

## Пример вывода
    [1] sed: JSON → key=value
    host=localhost
    port=8080
    debug=true

    [2] awk: добавляем префикс CONF_
    CONF_host=localhost
    CONF_port=8080
    CONF_debug=true

    [3] for: экспортируем переменные
      export CONF_host=localhost
      export CONF_port=8080
      export CONF_debug=true

    Проверка:
      CONF_host = localhost
      CONF_port = 8080
      CONF_debug = true

## Что было сложного
- `sed` с несколькими заменами в одной строке JSON
- `for` не умеет читать файл построчно → `mapfile` + массив
- `while read` работает в подоболочке → `mapfile` сохраняет переменные
- `export` внутри скрипта действует только в процессе скрипта

## Файлы
- `config.json` — тестовые данные
- `task04_config.sh` — скрипт
