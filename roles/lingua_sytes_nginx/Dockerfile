FROM nginx:stable-alpine3.23-perl
RUN mkdir -p /etc/nginx/certs
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY lingua.sytes.net.crt /etc/nginx/certs/
COPY lingua.sytes.net.key /etc/nginx/certs/
