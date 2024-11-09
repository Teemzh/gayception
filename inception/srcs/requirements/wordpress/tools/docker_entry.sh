#!/usr/bin/env bash

# Переходим в директорию, где будут размещены файлы WordPress
cd $WP_ROUTE

# Скачиваем ядро WordPress с перезаписью файлов, если они уже существуют
wp core download --force --allow-root

# Создаём файл конфигурации wp-config.php с настройками подключения к базе данных
wp config create --path=$WP_ROUTE --allow-root --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS --dbhost=$DB_HOST --dbprefix=wp_

# Проверяем, установлен ли WordPress, чтобы не выполнять установку повторно
if ! wp core is-installed --allow-root --path=$WP_ROUTE; then
    # Устанавливаем WordPress, задавая URL, заголовок сайта и данные администратора
    wp core install --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --allow-root
    
    # Создаём дополнительного пользователя с ролью "автор" (не администратор)
    wp user create $WP_USER $WP_EMAIL --role=author --user_pass=$WP_PASS --allow-root
fi

# Запускаем php-fpm, чтобы PHP-код WordPress мог исполняться сервером
php-fpm7.4 -F
