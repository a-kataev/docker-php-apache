ARG PHP_APACHE_IMAGE=
ARG GOMPLATE_VERSION=3.8.0

FROM "${PHP_APACHE_IMAGE}"

LABEL maintainer="Alex Kataev <dlyavsehpisem@gmail.com>"

ARG GOMPLATE_VERSION

ENV COMPOSER_NO_INTERACTION=1

RUN set -x && \
#
  apt-get update && \
  apt-get install -y --no-install-recommends git zip unzip curl ca-certificates vim net-tools procps less tree gnupg1 && \
#
  curl -s https://dl.google.com/linux/linux_signing_key.pub | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=true apt-key add - && \
  curl -sLO https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb && \
  dpkg -i mod-pagespeed-stable*.deb && \
  apt-get install -y -f && \
  rm -rf mod-pagespeed-stable*.deb && \
  a2enmod rewrite pagespeed && \
#
  rm -rf /var/lib/apt/lists/* && \
#
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
#
  curl -sL -o /usr/local/bin/gomplate \
    "https://github.com/hairyhenderson/gomplate/releases/download/v${GOMPLATE_VERSION}/gomplate_linux-amd64" && \
  chmod +x /usr/local/bin/gomplate && \
#
  rm -rf /var/www/*

WORKDIR /var/www

ADD docker-entrypoint.sh /

RUN set -x && \
  chmod +x /docker-entrypoint.sh && \
  /docker-entrypoint.sh php-ext-enable _ && \
  ln -s /docker-entrypoint.sh /usr/local/bin/cmd

ENTRYPOINT ["/docker-entrypoint.sh"]
