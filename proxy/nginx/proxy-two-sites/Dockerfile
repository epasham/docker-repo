FROM nginx:alpine

COPY sites.conf /etc/nginx/conf.d/sites.conf
RUN mkdir /var/www
COPY ./site1 /var/www/site1
COPY ./site2 /var/www/site2
