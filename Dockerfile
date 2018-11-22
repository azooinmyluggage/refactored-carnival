FROM nginx:latest

RUN ls -alh

ENV PORT 80

EXPOSE 80
