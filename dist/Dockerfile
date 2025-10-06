FROM node:18-alpine

ENV NODE_VERSION=18.20.8
ENV YARN_VERSION=1.22.22

RUN apk add --no-cache bash curl && \
    npm install -g serve

WORKDIR /app

COPY . .

EXPOSE 3000

CMD ["serve", "-s", ".", "-l", "3000"]

