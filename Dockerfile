FROM nginx:latest

RUN ls -alh

ENV PORT 8080

EXPOSE 8080
