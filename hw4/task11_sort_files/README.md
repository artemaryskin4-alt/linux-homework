# Задание 11: сортировка файлов по расширениям

## Что делает
Скрипт `task11_sort_files.sh`:

1. Создаёт тестовые файлы: `image1.jpg`, `image2.png`, `doc1.txt`,
   `doc2.pdf`, `script.sh`, `archive.tar.gz`.
2. Создаёт директории: `images`, `documents`, `scripts`, `archives`.
3. Через цикл `for` перебирает все файлы в текущей директории.
4. Через `case` определяет расширение и перемещает в нужную папку:
   - `.jpg`, `.png` → `images/`
   - `.txt`, `.pdf` → `documents/`
   - `.sh` → `scripts/`
   - `.tar.gz` → `archives/`
5. Выводит структуру через `ls -R`.

## Запуск
    ./task11_sort_files.sh

## Пример вывода
    [2] Перемещаем файлы по расширениям:
      image1.jpg → images/
      image2.png → images/
      doc1.txt → documents/
      doc2.pdf → documents/
      script.sh → scripts/
      archive.tar.gz → archives/

    [3] Структура директорий:
    archives:
    archive.tar.gz

    documents:
    doc1.txt  doc2.pdf

    images:
    image1.jpg  image2.png

    scripts:
    script.sh

## Что было сложного
- `for file in *` включает директории → `[ -f "$file" ] || continue`
- Пропуск самого скрипта: иначе он переместит себя в `scripts/`
- `case` с несколькими шаблонами через `|`
- `*.tar.gz` надо проверять до менее специфичных (порядок важен)
- `shopt -s nullglob` — если файлов нет, цикл не выполнится
- `mv "$file" "$target/"` — слэш гарантирует, что цель — директория

## Файлы
- `task11_sort_files.sh` — скрипт
- `images/`, `documents/`, `scripts/`, `archives/` — результат (в `.gitignore`)

