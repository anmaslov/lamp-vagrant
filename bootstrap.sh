#!/bin/bash

host_document_root="/home/vagrant"
apache_document_root="/var/www/html"
apache_config_file="/etc/apache2/apache2.conf"
project_folder_name='public'

php_config_file="/etc/php5/apache2/php.ini"
xdebug_config_file="/etc/php5/mods-available/xdebug.ini"

mysql_config_file="/etc/mysql/my.cnf"
DBUSER=vagrant
DBPASSWD=vagrant

echo "Start install"
sudo apt-get update

echo "Base package install"
sudo apt-get -y install curl git mc

echo "Apache install"
sudo apt-get -y install apache2
sudo rm -rf ${apache_document_root}
sudo ln -fs ${host_document_root}/${project_folder_name} ${apache_document_root}
a2enmod rewrite
sudo sed -i 's/AllowOverride None/AllowOverride All/g' ${apache_config_file}

echo "PHP Install"
sudo apt-get -y install php5 php5-curl php5-mysql libapache2-mod-php5 php5-gd php5-mcrypt php-apc php5-xdebug
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${php_config_file}
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" ${php_config_file}
sed -i "s/display_errors = Off/display_errors = On/g" ${php_config_file}

cat << EOF | sudo tee -a ${xdebug_config_file}
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

service apache2 restart

echo "Mysql install"
echo "mysql-server mysql-server/root_password password ${DBPASSWD}" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password ${DBPASSWD}" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
sudo apt-get -y install mysql-server mysql-client phpmyadmin

sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${mysql_config_file}

mysql -uroot -p${DBPASSWD} -e "CREATE DATABASE ${DBNAME}"

mysql -uroot -p${DBPASSWD} -e "CREATE USER '${DBUSER}'@'localhost' IDENTIFIED BY '${DBPASSWD}';
GRANT ALL PRIVILEGES ON *.* TO '${DBUSER}'@'localhost' WITH GRANT OPTION;
CREATE USER '${DBUSER}'@'%' IDENTIFIED BY '${DBPASSWD}';
GRANT ALL PRIVILEGES ON *.* TO '${DBUSER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES"

a2enconf phpmyadmin

echo "Restart services"
service mysql restart
service apache2 restart

echo "Installation complete"
