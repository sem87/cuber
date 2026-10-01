FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
# Добавляем текущую директорию в PYTHONPATH
ENV PYTHONPATH=/app
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "print('OK')" || exit 1
# Запуск скрипта
CMD ["python", "main.py"]


+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FROM python:3.12-slim

# Рабочая директория внутри контейнера
WORKDIR /app

# 1. Копируем ТОЛЬКО requirements.txt (для кэширования слоя Docker)
COPY requirements.txt .

# 2. Устанавливаем зависимости (с доверенными хостами для Т-Банка)
RUN pip install --no-cache-dir -r requirements.txt \
    --trusted-host opensource.tbank.ru \
    --trusted-host pypi.org \
    --trusted-host files.pythonhosted.org

# 3. Копируем весь остальной код проекта
COPY . .

# 4. Команда запуска (ЗАМЕНИ main.py на свой главный файл)
CMD ["python", "main.py"]
