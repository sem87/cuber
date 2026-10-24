FROM python:3.11-slim

# # 1. Аргументы прокси (передаются только при сборке)
# ARG HTTP_PROXY
# ARG HTTPS_PROXY
#
# # 2. Переменные окружения + ИГНОРИРОВАНИЕ (NO_PROXY)
# ENV HTTP_PROXY=$HTTP_PROXY \
#     HTTPS_PROXY=$HTTPS_PROXY \
#     http_proxy=$HTTP_PROXY \
#     https_proxy=$HTTPS_PROXY \
#     # ИГНОРИРУЕМ прокси для PyPI, GitHub и локальных адресов
#     NO_PROXY="pypi.org,files.pythonhosted.org,pythonhosted.org,github.com,localhost,127.0.0.1" \
#     no_proxy="pypi.org,files.pythonhosted.org,pythonhosted.org,github.com,localhost,127.0.0.1"

# 3. Системные сертификаты и GIT (ОБЯЗАТЕЛЬНО для скачивания с GitHub!)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 4. Кэширование зависимостей
COPY requirements.txt .

# Устанавливаем локальный пакет T-Invest, так как он в карантине на PyPI
RUN pip install --default-timeout=1000 --no-cache-dir -r requirements.txt \
    --trusted-host pypi.org \
    --trusted-host files.pythonhosted.org
# Устанавливаем локально
COPY ./local_packages/t_tech /usr/local/lib/python3.11/site-packages/t_tech
COPY ./local_packages/t_tech_investments-1.49.3.dist-info /usr/local/lib/python3.11/site-packages/t_tech_investments-1.49.3.dist-info
# Устанавливаем локально
# 5. Код проекта
COPY . .

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD python -c "print('OK')" || exit 1

CMD ["python", "cuberbot.py"]


# # ============================ Объявляем аргументы (значения передаются только при сборке)
# ARG HTTP_PROXY
# ARG HTTPS_PROXY
#
# # Передаем их в переменные окружения для pip и системных утилит
# ENV HTTP_PROXY=$HTTP_PROXY
# ENV HTTPS_PROXY=$HTTPS_PROXY
# ENV http_proxy=$HTTP_PROXY
# ENV https_proxy=$HTTPS_PROXY

# Создаем образ
# docker build --build-arg HTTP_PROXY="http://yUBkUP:xUoCe5@186.179.61.140:9768" --build-arg HTTPS_PROXY="http://yUBkUP:xUoCe5@186.179.61.140:9768" -t cuberbot .
# curl -I -x http://yUBkUP:xUoCe5@186.179.61.140:9768 https://opensource.tbank.ru
# Повершелл
# docker build --no-cache --build-arg HTTP_PROXY="http://yUBkUP:xUoCe5@186.179.61.140:9768" --build-arg HTTPS_PROXY="http://yUBkUP:xUoCe5@186.179.61.140:9768" -t sem87sem/cuberbot:latest .
# РОСТО БЕЗ ПРОКСИ (они в докер дектоп)
# docker build --no-cache -t sem87sem/cuberbot:latest .
# ПУШИМ В ДОКЕР ХАБ
# docker push sem87sem/cuberbot:latest
