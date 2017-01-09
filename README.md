# Заготовка сервера
## Докер
Остановить все контейнеры
docker stop $(docker ps -a -q)

Удалить все контейнеры
docker rm $(docker ps -a -q)

Delete all images  
docker rmi $(docker images -q)  
docker rmi $(docker images -q) && docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q)  

Залезть в консольку
docker exec -i -t docker_web_1 /bin/bash

##Тесты
###Отладка (файлы *.dev.spec.coffee)
./utils/test/debug.sh

###Запуск всех тестов (файлы *.spec.coffee)
./utils/test.sh

##Миграции
###Новая миграция
./utils/migration/new.sh name-for-migration

###Применить миграции
./utils/migration/up.sh

###Откатить последнюю
./utils/migration/down.sh



Request `http://localhost:3010/v1/user/login` time: 308 ms
Request `http://localhost:3010/v1/user/login` time: 550 ms
Request `http://localhost:3010/v1/user/login` time: 553 ms
Request `http://localhost:3010/v1/user/login` time: 601 ms
Request `http://localhost:3010/v1/user/login` time: 642 ms
Request `http://localhost:3010/v1/user/login` time: 678 ms
Request `http://localhost:3010/v1/user/login` time: 677 ms
Request `http://localhost:3010/v1/user/login` time: 721 ms
Request `http://localhost:3010/v1/user/login` time: 721 ms
Request `http://localhost:3010/v1/user/login` time: 722 ms


Request `http://localhost:3010/v1/user/login` time: 496 ms
Request `http://localhost:3010/v1/user/login` time: 516 ms
Request `http://localhost:3010/v1/user/login` time: 495 ms
Request `http://localhost:3010/v1/user/login` time: 501 ms
Request `http://localhost:3010/v1/user/login` time: 518 ms
Request `http://localhost:3010/v1/user/login` time: 520 ms
Request `http://localhost:3010/v1/user/login` time: 504 ms
Request `http://localhost:3010/v1/user/login` time: 502 ms
Request `http://localhost:3010/v1/user/login` time: 494 ms
Request `http://localhost:3010/v1/user/login` time: 505 ms






Request `http://localhost:3010/v1/user/login` time: 33822 ms
Request `http://localhost:3010/v1/user/login` time: 33848 ms
Stop 68165 ms


Request `http://localhost:3010/v1/user/login` time: 42913 ms
Request `http://localhost:3010/v1/user/login` time: 42976 ms
Stop 76926 ms


go
Request `http://localhost:3010/v1/user/login` time: 31844 ms
Stop 65350 ms
utime: 8652
stime: 197
total_time: 8849
cutime: 0
cstime: 0
total_time : 8849

node
Request `http://localhost:3010/v1/user/login` time: 33057 ms
Stop 66616 ms
utime: 9032
stime: 449
total_time: 9481
cutime: 0
cstime: 0
total_time : 9481



go
Request `http://localhost:3010/v1/user/login` time: 338 ms
Request `http://localhost:3010/v1/user/login` time: 340 ms
Request `http://localhost:3010/v1/user/login` time: 350 ms
Request `http://localhost:3010/v1/user/login` time: 380 ms
Request `http://localhost:3010/v1/user/login` time: 358 ms
Request `http://localhost:3010/v1/user/login` time: 357 ms
Request `http://localhost:3010/v1/user/login` time: 359 ms
Request `http://localhost:3010/v1/user/login` time: 369 ms
Request `http://localhost:3010/v1/user/login` time: 365 ms
Request `http://localhost:3010/v1/user/login` time: 401 ms
Stop 5815 ms
utime: 86
stime: 5
total_time: 91
cutime: 0
cstime: 0

node
Request `http://localhost:3010/v1/user/login` time: 369 ms
Request `http://localhost:3010/v1/user/login` time: 416 ms
Request `http://localhost:3010/v1/user/login` time: 470 ms
Request `http://localhost:3010/v1/user/login` time: 466 ms
Request `http://localhost:3010/v1/user/login` time: 477 ms
Request `http://localhost:3010/v1/user/login` time: 473 ms
Request `http://localhost:3010/v1/user/login` time: 507 ms
Request `http://localhost:3010/v1/user/login` time: 512 ms
Request `http://localhost:3010/v1/user/login` time: 514 ms
Request `http://localhost:3010/v1/user/login` time: 522 ms
Stop 5943 ms
utime: 309
stime: 33
total_time: 342
cutime: 0
cstime: 0
total_time : 342


go
Request `http://localhost:3010/v1/user/login` time: 31851 ms
Stop 64651 ms
utime: 8505
stime: 182
total_time: 8687
cutime: 0
cstime: 0
total_time : 8687

node
Request `http://localhost:3010/v1/user/login` time: 32184 ms
Stop 65435 ms
utime: 8846
stime: 349
total_time: 9195
cutime: 0
cstime: 0
total_time : 9195



go
Request `http://localhost:3010/v1/user/login` time: 6166 ms
Stop 38800 ms
utime: 127
stime: 172
total_time: 299
cutime: 0
cstime: 0
total_time : 299

go
Request `http://localhost:3010/v1/user/login` time: 3970 ms
Stop 36512 ms
utime: 115
stime: 169
total_time: 284
cutime: 0
cstime: 0
total_time : 284

node
Request `http://localhost:3010/v1/user/login` time: 6757 ms
Stop 39311 ms
utime: 669
stime: 169
total_time: 838
cutime: 0
cstime: 0
total_time : 838
# Установка



# Запуск сервера
`node bin\bin.js -e prod`

# Добавить в pm2
`pm2 start ./bin/bin.js -- -e test -p 16003 -wa`


# Оживить pm2
sudo pm2 kill
rm -rf ~/.npm/pm2
rm -rf ~/.pm2
sudo npm uninstall pm2 --g
sudo npm install pm2 --g


# Миграции

## Новая миграция
`cd ./app/sequelize`

`node ./../../node_modules/sequelize-cli/bin/sequelize migration:create --coffee true --name add-deletedAt-for-chat`

## Применение миграций
`node ./../../node_modules/sequelize-cli/bin/sequelize db:migrate --coffee true --env test`

## Откат последней
`node ./../../node_modules/sequelize-cli/bin/sequelize db:migrate:undo --coffee true`


# Тесты
Запускается через `grunt test`.  
Тесты актуальны  


# Важно!
`require` переопределяется через `./app/core/services/require`


# Сброс пароля дефолтного админа
`node bin/bin --run createDefaultAdmin`
