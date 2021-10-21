#!/bin/sh
set -x

/app/scripts/wait-for-it.sh ${DATABASE_URL}:5432 -- echo "db is up"
#npx prisma db push
yarn start
