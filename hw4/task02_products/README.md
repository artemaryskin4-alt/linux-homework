# Задание 2: обработка ценового каталога

## Что делает
Скрипт `task02_products.sh` обрабатывает `products.csv`:

1. `awk` — общая стоимость товаров по категориям (`Price * Stock`), сортировка по убыванию.
2. `sed` (или `awk`) — удаляет товары с `Stock = 0` → `available_products.csv`.
3. `while` + `awk` — выводит названия товаров с ценой > 100.

## Запуск
    ./task02_products.sh products.csv

## Файлы
- `products.csv` — тестовые данные
- `task02_products.sh` — скрипт
- `available_products.csv` — результат пункта 2

## Что было сложного
- `sed` не понимает поля — использовал `awk` для надёжности
- `while` в pipe (`| while`) работает в подоболочке
- `IFS=','` для разбора CSV в `read`
