#!/bin/bash

# Укажи свои 3 пути
DIRS=(
    "/path/to/project1"
    "/path/to/project2"
    "/path/to/project3"
)

for dir in "${DIRS[@]}"; do
    echo "=== $dir ==="
    cd "$dir" || { echo "Ошибка пути"; continue; }
    
    docker compose down
    sleep 5
    
    docker compose pull
    sleep 5
    
    docker compose up -d
    sleep 5
done
