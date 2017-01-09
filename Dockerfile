#!/usr/bin/env bash
FROM debian:jessie
# Переключаем в неинтерактивный режим — чтобы избежать лишних запросов
ENV DEBIAN_FRONTEND noninteractive

# Добавляем необходимые репозитарии и устанавливаем пакеты
RUN apt-get update
RUN apt-get install -y apt-transport-https

# Nodejs 6
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -
#RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
#RUN echo 'deb https://deb.nodesource.com/node_6.x jessie main' > /etc/apt/sources.list.d/nodesource.list
#RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y git

# Nginx
#RUN apt-get install -y nginx

# Проект
RUN apt-get install -y build-essential
COPY ./package.json /project/
WORKDIR "/project"
RUN npm install
RUN npm i pm2 -g
RUN npm i mocha -g

#RUN apt-get install -y golang-1.7
# Go
#RUN curl -O https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz
#RUN tar -C /usr/local -xzf go1.7.4.linux-amd64.tar.gz





# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.7.4
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 47fda42e46b4c3ec93fa5d4d4cc6a748aa3f9411a2a2b7e08e3a6d80d753ec8b

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /usr/local -xzf golang.tar.gz \
	&& rm golang.tar.gz

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH


RUN go get github.com/asaskevich/govalidator
RUN go get github.com/julienschmidt/httprouter
RUN go get -u github.com/jinzhu/gorm
RUN go get github.com/jinzhu/gorm/dialects/postgres
RUN go get github.com/robfig/cron
RUN go get github.com/satori/go.uuid
RUN go get golang.org/x/crypto/bcrypt
RUN go get github.com/valyala/fasthttp
RUN go get github.com/mailru/easyjson

#COPY ./docker/go-wrapper /usr/local/bin/
#RUN chmod 777 /usr/local/bin/go-wrapper
COPY ./go_app /go/src/go_app
#RUN find /go/src/go_app/ -type f -print0 | xargs -0 sed -i 's/(\.\.\/)+go_app/go_app/g'
RUN find /go/src/go_app/ -type f -exec sed -i -r 's/(\.\.\/)+go_app/go_app/g' {} \;
#RUN sed 's/\.\.\/go_app/go_app/g' </go/src/go_app/main.go >/go/src/go_app/main1.go
#RUN go get -d -v
RUN go install go_app













WORKDIR "/project"

RUN mkdir -p /srv/server
#RUN mkdir -p /root/go/bin
#RUN mkdir -p /root/go/src

#ENV GOROOT=/root/go
#ENV GOPATH=/usr/local/go
#ENV PATH=$PATH:/usr/local/go/bin:/root/go/bin
#RUN echo "export GOROOT=/root/go" >> /root/.bashrc
#RUN echo "export GOPATH=/usr/local/go" >> /root/.bashrc
#RUN echo "export PATH=$PATH:/usr/local/go/bin:/root/go/bin" >> /root/.bashrc

#RUN cat /root/.bashrc

#COPY ./docker/go-install.sh /project/docker/
#RUN go get "github.com/asaskevich/govalidator"
#RUN ./docker/go-install.sh

COPY . /project
RUN find ./docker -type f -exec chmod +x {} \;
RUN find ./utils -type f -exec chmod +x {} \;

# Объявляем, какой порт этот контейнер будет транслировать
EXPOSE 80

# sleep 5s - Ждем БД
# pm2 logs > /dev/null - Русские символы ломают виндовую консоль докера
#ENTRYPOINT sleep 5s && \
#    sh /project/env.sh \
#    echo "Migration" && \
#    /project/utils/migration/up.sh && \
#    echo "Run" && \
#    pm2 start /project/docker/process.json > /dev/null && \
#    pm2 logs > /dev/null
#
#CMD sleep 5s && \
#    sh /project/env.sh \
#    echo "Run" && \
#    pm2 start /project/docker/process.json > /dev/null && \
#    pm2 logs > /dev/null

CMD sleep 5s && \
    sh /project/env.sh \
    echo "Migration" && \
    /project/utils/migration/up.sh && \
    echo "Run" && \
    go_app -port=80
