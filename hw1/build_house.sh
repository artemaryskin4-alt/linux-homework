#!/bin/bsh
#build_house.sh - строит дом с двумя этажами, комнатами и мебелью

set -e
#Создаем корневую директорию
house="house"

#Cоздаем дом
mkdir -p "$house"


#--------Этаж 1----------------
floor1="$house/floor1"
mkdir -p "$floor1"

#Комната 1: Кухня
mkdir -p "$floor1/kitchen/fridge"
echo -e "milk\nbread\neggs\ncheese" >"$floor1/kitchen/fridge/products.txt"

#Комната 2: Гостиная
mkdir -p "$floor1/living_room/sofa"
echo -e "pillow1\npillow2\npillow3\nblanket" >"$floor1/living_room/sofa/cushions.txt"

#Комната 3: Спальня
mkdir -p "$floor1/bedroom/bed"
echo -e "soft pillow" > "$floor1/bedroom/bed/pillow.txt"

#---------Этаж 2---------------
floor2="$house/floor2"
mkdir -p "$floor2"

#Комната 1: Спальня
mkdir -p "$floor2/bedroom/wardrobe"
echo -e "T-shirt\njeans\njacket\npajamas" >"$floor2/bedroom/wardrobe/clothes.txt"

#Комната 2: Ванная
mkdir -p "$floor2/bathroom/shelf"
echo -e "towel 1\ntowel 2\nsoap" > "$floor2/bathroom/shelf/towels.txt"

#Готово
echo "Дом построен:"
ls -R "$house"

