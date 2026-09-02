# Imagem base da Microsoft: PHP 8.3 (CLI), Composer, git, usuário não-root "vscode".
# PHP 8.3 é a faixa recomendada para Moodle 5.2.
FROM mcr.microsoft.com/devcontainers/php:1-8.3-bookworm

# ---------------------------------------------------------------------------
# Banco de dados e bibliotecas de sistema exigidas pelas extensões do PHP.
# DEBIAN_FRONTEND=noninteractive evita que a instalação trave pedindo confirmação.
# ---------------------------------------------------------------------------
# A imagem base traz uma fonte apt do yarn com chave GPG rotacionada; removida porque
# o build usa npm, não yarn.
RUN rm -f /etc/apt/sources.list.d/yarn.list \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev \
        libicu-dev libxml2-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Extensões nativas do PHP que o Moodle 5.2 checa no instalador e que não
# vêm na imagem base. As demais (curl, mbstring, dom, iconv, xml, tokenizer,
# openssl, sodium, fileinfo, ...) já estão compiladas na imagem.
# ---------------------------------------------------------------------------
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        mysqli pdo_mysql zip gd intl exif soap opcache

# ---------------------------------------------------------------------------
# Ajustes de php.ini exigidos/recomendados pelo Moodle.
# ---------------------------------------------------------------------------
RUN { \
        echo "max_input_vars = 5000"; \
        echo "memory_limit = 256M"; \
        echo "upload_max_filesize = 128M"; \
        echo "post_max_size = 128M"; \
        echo "max_execution_time = 300"; \
    } > /usr/local/etc/php/conf.d/moodle.ini

# Xdebug desligado por padrão (a imagem base o deixa em "debug", que tenta um
# debugger inexistente e polui toda saída). O moodle-coverage religa via
# XDEBUG_MODE=coverage quando precisa. zzz- garante que sobrescreve o ini do Xdebug.
RUN echo "xdebug.mode=off" > /usr/local/etc/php/conf.d/zzz-xdebug-off.ini

# ---------------------------------------------------------------------------
# PHP_CodeSniffer + padrão de código do Moodle (moodlehq/moodle-cs), num
# diretório Composer isolado do sistema. O binário fica em /usr/local/bin/phpcs
# e o standard "moodle" já registrado — é o que o hook de pre-commit espera.
# ---------------------------------------------------------------------------
ENV COMPOSER_HOME=/usr/local/composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer global config --no-plugins allow-plugins true \
    && composer global require --no-interaction --no-progress "moodlehq/moodle-cs:^3.0" \
    && ln -s /usr/local/composer/vendor/bin/phpcs /usr/local/bin/phpcs \
    && ln -s /usr/local/composer/vendor/bin/phpcbf /usr/local/bin/phpcbf \
    && phpcs --config-set default_standard moodle \
    && phpcs -i \
    && chmod -R a+rX /usr/local/composer

# MariaDB precisa do diretório de runtime; o serviço é iniciado no start.sh.
RUN mkdir -p /var/run/mysqld && chown mysql:mysql /var/run/mysqld
