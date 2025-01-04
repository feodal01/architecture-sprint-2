#!/bin/bash

# Настройки
BASE_URL="http://localhost:8080" # Замените на ваш URL, если необходимо
ENDPOINT="/helloDoc/users"
TEST_COUNT=5 # Количество тестов после прогрева

# Функция для измерения времени выполнения запроса
measure_request_time() {
  local url=$1
  local result
  result=$(curl -o /dev/null -s -w "%{time_total}\n" "$url")
  echo "$result"
}

# Прогрев
echo "Выполняется прогрев..."
warm_up_time=$(measure_request_time "$BASE_URL$ENDPOINT")
warm_up_time_ms=$(echo "$warm_up_time * 1000" | bc -l)
echo "Прогрев завершен. Время: $warm_up_time_ms мс"

# Последующие тесты
echo -e "\nВыполняются тестовые запросы..."
declare -a times
for ((i = 1; i <= TEST_COUNT; i++)); do
  elapsed_time=$(measure_request_time "$BASE_URL$ENDPOINT")
  times+=("$elapsed_time")
  elapsed_time_ms=$(echo "$elapsed_time * 1000" | bc -l)
  echo "Запрос $i: ${elapsed_time_ms} мс"
done

# Проверка времени выполнения
echo -e "\nРезультаты тестов:"
for ((i = 0; i < ${#times[@]}; i++)); do
  elapsed_time_ms=$(echo "${times[$i]} * 1000" | bc -l)
  if (( $(echo "$elapsed_time_ms < 100" | bc -l) )); then
    echo "Запрос $((i + 1)): ${elapsed_time_ms} мс - OK"
  else
    echo "Запрос $((i + 1)): ${elapsed_time_ms} мс - FAIL"
  fi
done
