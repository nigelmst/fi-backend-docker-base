FROM php:8.0-fpm-alpine

# Install system dependencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories
ARG APK_COMMON_DEPENDENCIES="dcron busybox-suid libcap curl zip unzip git"
RUN apk add --update --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/latest-stable/main $APK_COMMON_DEPENDENCIES

# Install PHP extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/bin/
ARG PHP_EXTENSIONS="intl bcmath gd pdo_mysql opcache uuid exif pcntl zip imagick exif"
RUN install-php-extensions $PHP_EXTENSIONS

# Install supervisord
COPY --from=ochinchina/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/supervisord

# Install ffmpeg
COPY --from=mwader/static-ffmpeg:4.4.0 /ffmpeg /usr/local/bin
COPY --from=mwader/static-ffmpeg:4.4.0 /ffprobe /usr/local/bin

# Install caddy
COPY --from=caddy:2.4.3 /usr/bin/caddy /usr/local/bin/caddy
RUN setcap 'cap_net_bind_service=+ep' /usr/local/bin/caddy

# Install composer 2
COPY --from=composer/composer:2.0.14 /usr/bin/composer /usr/local/bin/composer

# Add & switch to non-root user: 'app'
ENV NON_ROOT_GROUP=${NON_ROOT_GROUP:-app}
ENV NON_ROOT_USER=${NON_ROOT_USER:-app}
RUN addgroup -S $NON_ROOT_GROUP && adduser -S $NON_ROOT_USER -G $NON_ROOT_GROUP
RUN addgroup $NON_ROOT_USER wheel
