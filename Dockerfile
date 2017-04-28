FROM php:7.0.18-fpm

MAINTAINER SRE@leafgroup.com

# System env variables
ENV environment development

# Install dependencies and PHP packages
RUN mkdir -p /data \
  && apt-get update \
  && apt-get install -y \
  build-essential \
  curl \
  zlib1g-dev \
  zip \
  unzip \
  libmcrypt-dev \
  pkg-config \
  libmemcached-dev \
  libmemcached11 \
  libmemcachedutil2 \
  libmemcached-dev --no-install-recommends \
  && docker-php-ext-install mcrypt zip
  #&& docker-php-ext-install curl mcrypt json mbstring mysqli zip \

# Imagick
RUN runtimeRequirements="libmagickwand-6.q16-dev --no-install-recommends" \
    && apt-get update && apt-get install -y ${runtimeRequirements} \
    && ln -s /usr/lib/x86_64-linux-gnu/ImageMagick-6.8.9/bin-Q16/MagickWand-config /usr/bin/ \
    && pecl install imagick-3.4.0RC6 \
    && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
    && rm -rf /var/lib/apt/lists/*

# Install Memcached for php 7
RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

# Install Composer for Laravel
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

WORKDIR /data

EXPOSE 9000
CMD ["php-fpm"]
Add Comment