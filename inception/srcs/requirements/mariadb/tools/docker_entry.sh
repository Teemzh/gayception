#!/usr/bin/env bash

# Добавляем необходимые настройки в конфигурационный файл MariaDB.
# $DB_CONF_ROUTE — это путь к файлу конфигурации, который определяется в .env файле
echo >> $DB_CONF_ROUTE              # Добавляем пустую строку в конец файла (для разделения).
echo "[mysqld]" >> $DB_CONF_ROUTE    # Указываем, что ниже идут настройки для сервера MySQL.
echo "bind-address=0.0.0.0" >> $DB_CONF_ROUTE  # Настраиваем MariaDB на прием запросов с любого IP-адреса (для доступа извне контейнера).

# Создаем системные таблицы в MariaDB
# --datadir=$DB_INSTALL указывает путь для хранения данных базы данных.
mysql_install_db --datadir=$DB_INSTALL

# Запускаем MariaDB в безопасном режиме (mysqld_safe) в фоновом режиме.
# Это следит за процессом MariaDB и перезапускает его при сбоях.
mysqld_safe &
mysql_pid=$!  # Сохраняем идентификатор процесса MariaDB, чтобы можно было дождаться завершения этого процесса позже.

# Ожидаем, пока MariaDB станет доступной для соединений.
# Команда mysqladmin ping проверяет статус MariaDB.
until mysqladmin ping >/dev/null 2>&1; do
  echo -n "."; sleep 0.2  # Пока MariaDB не запущена, выводим точку каждые 0.2 секунды.
done

# Подключаемся к MariaDB и выполняем команды для создания базы данных и настройки пользователей.
mysql -u root -e "
    CREATE DATABASE $DB_NAME;  # Создаем базу данных с именем, заданным переменной $DB_NAME (например, wordpress).
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';  # Задаем пароль для пользователя root, используя значение $DB_ROOT_PASS.
    GRANT ALL ON $DB_NAME.* TO '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';  # Создаем пользователя с именем $DB_USER и паролем $DB_PASS, а также даем ему все права на базу данных $DB_NAME.
    FLUSH PRIVILEGES;  # Обновляем привилегии, чтобы изменения вступили в силу.
"

# Ждем завершения процесса MariaDB
# wait $mysql_pid удерживает процесс MariaDB активным, чтобы контейнер не завершался.
wait $mysql_pid
