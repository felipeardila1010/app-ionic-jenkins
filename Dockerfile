# specify the node base image with your desired version node:<version>
FROM node:14-alpine

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git
# replace this with your application's default port
EXPOSE 8888
