
# Задание 5: границы протеин-кодирующих генов (unprocessed_pseudogene)
## Что делает
Скрипт `task_genome.sh` из GFF3-аннотации GENCODE:

1. Создаёт директорию `terminal_task/results/`.
2. Фильтрует GFF3:
   - только строки с `gene` в 3-й колонке;
   - только строки с `gene_type=unprocessed_pseudogene` в 9-й колонке;
   - оставляет колонки 1, 4, 5, 7, 9;
   - из 9-й колонки — только `gene_name=...`.
3. Модифицирует координаты:
   - `+` цепь: `start` остаётся, `end = start + 1`;
   - `-` цепь: `start = end`, `end = end + 1`.
4. Записывает в `terminal_task/results/result.tsv`.

## Запуск
    ./task_genome.sh

## Данные
GFF3-аннотация GENCODE v41:
https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_41/gencode.v41.basic.annotation.gff3.gz

## Пример вывода
    chr1    29570   29571   -   WASH7P
    chr1    52473   52474   +   OR4G4P
    chr1    182696  182697  +   DDX11L17
    ...

## Логика координат
- `+` цепь: транскрипция слева направо, «левая» граница = start.
  Правая не включается → `[start, start+1)`.
- `-` цепь: транскрипция справа налево, «левая» граница = end.
  Правая не включается → `[end, end+1)`.

## Файлы
- `task_genome.sh` — скрипт
- `data/gencode.v41.basic.annotation.gff3` — данные (в .gitignore)
- `terminal_task/results/result.tsv` — результат
