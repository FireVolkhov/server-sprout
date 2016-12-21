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

# Redis
#RUN apt-get install -y wget
RUN apt-get install -y build-essential
#RUN apt-get install -y tcl8.5
#RUN wget http://download.redis.io/releases/redis-stable.tar.gz
#RUN tar xzf redis-stable.tar.gz
#WORKDIR "/redis-stable"
#RUN make
#RUN make test
#RUN make install
#WORKDIR "/redis-stable/utils"
#RUN ./install_server.sh
#WORKDIR "/"

# Postgresql
#RUN apt-get install -y postgresql-9.4 postgresql-client-9.4
# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
#USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
#RUN /etc/init.d/postgresql start &&\
#    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
#    createdb -O docker docker
# Add VOLUMEs to allow backup of config, logs and databases
#VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

#USER root

# Nginx
RUN apt-get install -y nginx

# Проект
COPY ./package.json /project/
WORKDIR "/project"
RUN npm install
RUN npm i pm2 -g

COPY . /project

# Объявляем, какой порт этот контейнер будет транслировать
EXPOSE 80

# Запуск
CMD ["/bin/bash", "/project/docker-start.sh"]
