# Задание 9: переименование файлов

## Что делает
Скрипт `task09_rename.sh`:

1. Создаёт 5 файлов `document1.txt` … `document5.txt`.
2. Создаёт директорию `renamed`.
3. Через цикл `while` читает список файлов `document*.txt` (через `ls`).
4. Для каждого файла заменяет `document` на `file`: `document1.txt` → `file1.txt`.
5. Перемещает переименованный файл в `renamed/`.
6. Выводит список файлов в `renamed/`.

## Запуск
    ./task09_rename.sh

## Пример вывода
    [0] Создаём 5 файлов document1.txt ... document5.txt:
      Создан: document1.txt
      ...
      Создан: document5.txt

    [1] Создана директория: renamed

    [2] Переименовываем и перемещаем:
      document1.txt → renamed/file1.txt
      document2.txt → renamed/file2.txt
      ...
      document5.txt → renamed/file5.txt

    [3] Содержимое renamed:
    file1.txt
    file2.txt
    file3.txt
    file4.txt
    file5.txt

## Результат
    renamed/
    ├── file1.txt
    ├── file2.txt
    ├── file3.txt
    ├── file4.txt
    └── file5.txt

## Что было сложного
- `for file in $(ls ...)` ломается на пробелах в именах → `while read`
- `while` в pipe работает в подоболочке (переменные не сохраняются)
- `${var/old/new}` — замена в переменной: `document3.txt` → `file3.txt`
- `2>/dev/null` у `ls` — скрыть ошибку, если файлов нет

## Файлы
- `task09_rename.sh` — скрипт
- `renamed/` — результат (в `.gitignore`)
