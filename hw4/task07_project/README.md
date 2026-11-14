# Задание 7: создание структуры проекта

## Что делает
Скрипт `task07_project.sh` создаёт структуру проекта:

1. Корневую директорию `my_project`.
2. Поддиректории: `src`, `docs`, `tests`, `build`.
3. В каждой — подпапки `images`, `scripts`, `data`.
4. Цикл `for` выводит список всех созданных директорий.
5. Создаёт пустой файл `README.md` в корне проекта.

## Запуск
    ./task07_project.sh
    ./task07_project.sh my_other_project   # своё имя

## Пример вывода
    === Создание структуры проекта: my_project ===

    Создана директория: my_project
    Создана директория: my_project/src
    Создана директория: my_project/src/images
    ...

    [4] Список всех директорий (for):
      Создана директория: my_project
      Создана директория: my_project/build
      ...

    Создан файл: my_project/README.md

    === Готово ===

## Структура
    my_project/
    ├── README.md
    ├── src/
    │   ├── images/
    │   ├── scripts/
    │   └── data/
    ├── docs/
    │   ├── images/
    │   ├── scripts/
    │   └── data/
    ├── tests/
    │   ├── images/
    │   ├── scripts/
    │   └── data/
    └── build/
        ├── images/
        ├── scripts/
        └── data/

## Что было сложного
- Вложенные циклы `for` для создания подпапок
- `for` по выводу `find` через `mapfile` (иначе ломается на пробелах)
- `"${arr[@]}"` — кавычки обязательны, иначе пробелы в элементах ломают цикл
- `mkdir -p` — создаёт родителей автоматически

## Файлы
- `task07_project.sh` — скрипт
