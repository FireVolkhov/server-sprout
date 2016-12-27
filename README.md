# Заготовка сервера
## Докер
Остановить все контейнеры
docker stop $(docker ps -a -q)

Удалить все контейнеры
docker rm $(docker ps -a -q)

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
