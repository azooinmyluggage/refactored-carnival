FROM nginx:latest

RUN ls -alh

ENV PORT 80

EXPOSE 80



#FROM nginx:alpine
#COPY default.conf /etc/nginx/conf.d/default.conf
#COPY index.html /usr/share/nginx/html/index.html
