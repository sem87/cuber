FROM python:3.11-slim

# Объявляем аргументы (значения передаются только при сборке)
ARG HTTP_PROXY
ARG HTTPS_PROXY

# Передаем их в переменные окружения для pip и системных утилит
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTPS_PROXY

WORKDIR /app

# Копируем только requirements.txt для эффективного кэширования
COPY requirements.txt .

# Устанавливаем зависимости
RUN pip install --no-cache-dir -r requirements.txt \
    --trusted-host opensource.tbank.ru \
    --trusted-host pypi.org \
    --trusted-host files.pythonhosted.org

# Копируем весь остальной код
COPY . .

# PYTHONPATH не нужен: WORKDIR автоматически добавляется в sys.path

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "print('OK')" || exit 1

CMD ["python", "cuberbot.py"]


# Создаем образ
# docker build \
#   --build-arg HTTP_PROXY="http://login:password@ip:port" \
#   --build-arg HTTPS_PROXY="http://login:password@ip:port" \
#   -t cuberbot .
# Запуск контейнера примерно
# docker run -d \
#   --name cuberbot_run \
#   --env-file .env \
#   --restart unless-stopped \
#   cuberbot