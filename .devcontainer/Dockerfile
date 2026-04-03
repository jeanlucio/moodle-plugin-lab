# 1. Imagem oficial da Microsoft com PHP 8.3 (ideal para Moodle 5.0+)
FROM mcr.microsoft.com/devcontainers/php:8.3

# 2. Instalação do banco de dados (MariaDB) e bibliotecas do sistema
# O export DEBIAN_FRONTEND evita que a instalação trave pedindo confirmações
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y mariadb-server libzip-dev libpng-dev libicu-dev libxml2-dev

# 3. Instalação nativa das extensões do PHP exigidas pelo Moodle
RUN docker-php-ext-install mysqli pdo_mysql zip gd intl xml soap opcache

# 4. Ajuste crucial de segurança e performance para o Moodle 5.2
# Aumenta o limite de variáveis para evitar que a instalação quebre no final
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle-vars.ini