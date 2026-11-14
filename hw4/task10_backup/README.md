# Задание 10: резервное копирование по дням

## Что делает
Скрипт `task10_backup.sh`:

1. Создаёт директорию `backup`.
2. Внутри неё — 7 директорий `day_1` … `day_7`.
3. В каждой — файл `info.txt` с содержимым `Резервная копия за день X`.
4. Через цикл `for` копирует `info.txt` из каждой директории
   в `all_backups/`, переименовывая в `info_day_X.txt`.
5. Выводит содержимое `all_backups`.

## Запуск
    ./task10_backup.sh

## Пример вывода
    [2] Создаём 7 директорий с info.txt:
      Создано: backup/day_1/info.txt
      ...
      Создано: backup/day_7/info.txt

    [3] Копируем info.txt в all_backups/:
      backup/day_1/info.txt → all_backups/info_day_1.txt
      ...
      backup/day_7/info.txt → all_backups/info_day_7.txt

    [4] Содержимое all_backups:
    info_day_1.txt
    ...
    info_day_7.txt

## Структура
    backup/
    ├── day_1/
    │   └── info.txt
    ├── day_2/
    │   └── info.txt
    ...
    └── day_7/
        └── info.txt

    all_backups/
    ├── info_day_1.txt
    ...
    └── info_day_7.txt

## Что было сложного
- `for` с переменной в диапазоне → `seq 1 "$DAYS"` (а не `{1..$DAYS}`)
- `mkdir -p` — создаёт вложенные директории без ошибок
- `cp` с переименованием — копирует и меняет имя
- Защита от повторного запуска (директории уже существуют)

## Файлы
- `task10_backup.sh` — скрипт
- `backup/`, `all_backups/` — результат (в `.gitignore`)

