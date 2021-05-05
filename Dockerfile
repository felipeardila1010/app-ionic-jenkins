# specify the node base image with your desired version node:<version>
FROM node:14-alpine

# Create app directory
WORKDIR /usr/src/app

# Bundle app source
COPY package*.json ./
COPY . .

# Install dependencies
RUN apk --no-cache add git

# replace this with your application's default port
EXPOSE 8888
