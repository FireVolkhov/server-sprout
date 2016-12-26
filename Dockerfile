#!/usr/bin/env bash
FROM debian
# Переключаем в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive

# Добавляем необходимые репозитарии и устанавливаем пакеты
RUN apt-get update
RUN apt-get install -y apt-transport-https

# Nodejs 6
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get install -y nodejs

# Nginx
RUN apt-get install -y nginx

# Проект
RUN apt-get install -y build-essential
COPY ./package.json /project/
WORKDIR "/project"
RUN npm install
RUN npm i pm2 -g
RUN npm i mocha -g

COPY . /project
RUN find ./docker -type f -exec chmod +x {} \;
RUN find ./utils -type f -exec chmod +x {} \;

# Объявляем, какой порт этот контейнер будет транслировать
EXPOSE 80

# Запуск
CMD ["/bin/bash", "/project/docker/container-init.sh"]
