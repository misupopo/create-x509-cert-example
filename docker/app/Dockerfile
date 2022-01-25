FROM node:latest

RUN apt-get update

RUN apt-get install nginx -y

ENV APP_ROOT /app

#RUN #mkdir -p $APP_ROOT
WORKDIR $APP_ROOT

#ADD ./app/package.json $APP_ROOT
ADD ./app $APP_ROOT

RUN npm i

CMD ["/bin/bash", "-c", "service nginx restart; node app.js"]

#COPY ./conf/app/nginx.conf /etc/nginx/
#
#ENV APP_ROOT /app
#WORKDIR $APP_ROOT
#
#RUN npm i
