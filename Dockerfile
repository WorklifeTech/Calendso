FROM node:14-alpine as BUILD_IMAGE

RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY package.json yarn.lock ./
COPY prisma prisma

# install dependencies
RUN yarn install --frozen-lockfile 
# --prefer-offline --ignore-scripts --production 

COPY . .

# build
RUN yarn build

# remove dev dependencies
RUN npm prune --production

FROM node:14-alpine

WORKDIR /app

# copy from build image
COPY --from=BUILD_IMAGE /app/next.config.js ./
COPY --from=BUILD_IMAGE /app/next-i18next.config.js ./
COPY --from=BUILD_IMAGE /app/package.json ./package.json
COPY --from=BUILD_IMAGE /app/node_modules ./node_modules
COPY --from=BUILD_IMAGE /app/.next ./.next
COPY --from=BUILD_IMAGE /app/public ./public
COPY --from=BUILD_IMAGE /app/prisma ./prisma

COPY  scripts scripts

ENV NODE_ENV production

EXPOSE 3000
CMD ["/app/scripts/start.sh"] 