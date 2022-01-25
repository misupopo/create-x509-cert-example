FROM nginx:alpine

COPY ./conf/app/nginx.conf /etc/nginx/

ENV APP_ROOT /app
WORKDIR $APP_ROOT

RUN npm i
