FROM alpine:latest

RUN apk update && apk upgrade

# OS toolchain
RUN apk add bash sudo curl git nano wget \
            nginx supervisor rsyslog

# PHP extensions
RUN apk add php php-fpm \
            php-curl php-openssl

# Install composer, dependency manager for php (@see https://getcomposer.org)
RUN apk add composer

# Prepare working directory
RUN mkdir -p /var/www/comdirect-php/latest
WORKDIR /var/www/comdirect-php/latest
COPY ./src .
RUN chown -R nginx:nginx /var/www/comdirect-php/latest

# Install application (since the mounted volume overwrites the content in workdir this is done in docker-compose.yml again)
RUN sudo su - nginx -s /bin/bash -c "cd /var/www/comdirect-php/latest && composer install"

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["/bin/bash", "-c", "php-fpm81 && chmod 755 /var/www/comdirect-php/latest/* && nginx -g 'daemon off;'"]