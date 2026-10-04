FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .

# 2. Устанавливаем зависимости (с доверенными хостами для Т-Банка)
RUN pip install --no-cache-dir -r requirements.txt \
    --trusted-host opensource.tbank.ru \
    --trusted-host pypi.org \
    --trusted-host files.pythonhosted.org
COPY . .
# Добавляем текущую директорию в PYTHONPATH     надо ли это???????????????
ENV PYTHONPATH=/app
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "print('OK')" || exit 1
# Запуск скрипта
CMD ["python", "cuberbot.py"]
