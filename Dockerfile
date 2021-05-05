# specify the node base image with your desired version node:<version>
FROM node:14-alpine

RUN apk --no-cache add git
WORKDIR /usr/src/app
COPY package*.json ./

# replace this with your application's default port
EXPOSE 8888
