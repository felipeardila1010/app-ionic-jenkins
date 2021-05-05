# specify the node base image with your desired version node:<version>
FROM node:14-alpine

# Create app directory
WORKDIR /

# Bundle app source
COPY package*.json ./
COPY . .
RUN ls
RUN pwd
RUN echo "NODE Version:" && node --version
RUN echo "NPM Version:" && npm --version

# Install dependencies
RUN apk --no-cache add git

# replace this with your application's default port
EXPOSE 8888
