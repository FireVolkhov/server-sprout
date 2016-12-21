#!/usr/bin/env bash
rm -rf ./pdf_converter
git clone https://bitbucket.org/Virrus2000/pdf_converter.git
cd ./pdf_converter/
bash ./gradlew iD
cd ..

git checkout .;
git fetch;
git checkout origin/prod;
npm install;
cd ./app/sequelize;
node ./../../node_modules/sequelize-cli/bin/sequelize db:migrate --coffee true --env production;
cd ../..;
pm2 delete process-prod.json;
pm2 start process-prod.json;
exit 0;
