#Устанавливаем необходимые репозитории и обновляем
yum install epel-release -y
yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y
rpm -Uvh https://mirror.webtatic.com/yum/el7/epel-release.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
yum update -y

#Устанавливаем необходимые программы
yum install yum-utils nano wget zip unzip php56w php56w-opcache php56w-mysqlnd install mariadb mariadb-server nginx httpd -y

#Отключаем SELINUX и Firewall
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config
systemctl disable firewalld
systemctl stop firewalld

mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.old
wget -P /etc/nginx/ https://raw.githubusercontent.com/vlembikov/nginx-apache-mariadb/master/nginx.conf
wget -P /etc/nginx/conf.d/ https://raw.githubusercontent.com/vlembikov/nginx-apache-mariadb/master/wordpress.nginx.conf

#Если у вас MySQL 5.7.6 и новее или MariaDB 10.1.20 и новее
#echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'fkg7h4f3';FLUSH PRIVILEGES;" | mysql --password=
echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('fkg7h4f3');FLUSH PRIVILEGES;" | mysql --password=

mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.old
wget -P /etc/httpd/conf/ https://raw.githubusercontent.com/vlembikov/nginx-apache-mariadb/master/httpd.conf
wget -P /etc/httpd/conf.d/ https://raw.githubusercontent.com/vlembikov/nginx-apache-mariadb/master/wordpress.httpd.conf

#Создаем необходимые каталоги для сайта и загружаем его туда
mkdir -p /var/www/wordpress/{www,tmp}
mkdir -p /var/www/wordpress/log/{nginx,apache}
wget -P /var/www/wordpress/www/ https://ru.wordpress.org/latest-ru_RU.zip
unzip /var/www/wordpress/www/latest-ru_RU.zip -d /var/www/wordpress/www/
mv /var/www/wordpress/www/wordpress/* /var/www/wordpress/www/
rmdir /var/www/wordpress/www/wordpress
rm -rf /var/www/wordpress/www/latest-ru_RU.zip
chown -R apache:apache /var/www/wordpress/*
chmod -R 775 /var/www/wordpress/*

#Запускаем Nginx, Apache, MariaDB
systemctl enable nginx
systemctl start nginx
systemctl enable httpd
systemctl start httpd
systemctl enable mariadb
systemctl start mariadb
