FROM ubuntu:22.04
RUN export DEBIAN_FRONTEND=noninteractive;ln -fs /usr/share/zoneinfo/Europe/Budapest /etc/localtime;apt update -y;apt install -y tzdata;dpkg-reconfigure --frontend noninteractive tzdata;apt install -y mariadb-client supervisor vim zoneminder mariadb-server-10.6
RUN /etc/init.d/mariadb stop
ENV DB_HOST=localhost
ENV DB_PASS=zmpass
ENV DB_NAME=zm
ENV DB_USER=zmuser
ENV MYSQL_ROOT_PWD=root
ENV RESET=false
ARG UID=1000
ARG GID=1000
COPY ./my.cnf /etc/mysql/my.cnf
RUN chmod 600 /etc/mysql/my.cnf
EXPOSE 80/tcp
RUN echo "[mysqld] sql_mode = NO_ENGINE_SUBSTITUTION" > /etc/mysql/my.cnf
RUN chmod 740 /etc/zm/zm.conf
RUN chown root:www-data /etc/zm/zm.conf
COPY ./zoneminder.conf /etc/apache2/conf-available/zoneminder.conf
RUN chown -R www-data:www-data /etc/apache2
COPY ./htaccess2 /usr/share/zoneminder/www/api/.htaccess
COPY ./htaccess2 /usr/share/zoneminder/www/api/app/.htaccess
COPY ./htaccess1 /usr/share/zoneminder/www/api/app/webroot/.htaccess
RUN echo "ServerName zm.prodet.org" >> /etc/apache2/apache2.conf
RUN chown -R www-data:www-data /usr/share/zoneminder
RUN chown -R www-data:www-data /usr/lib/zoneminder
RUN a2enmod cgi rewrite expires headers
RUN a2enconf zoneminder
RUN sed -i "s/;date.timezone =/date.timezone=Europe\/Budapest/g" /etc/php/*/apache2/php.ini
COPY ./start.cnf /start.sh
RUN apt upgrade -y
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ENTRYPOINT ["/bin/bash", "/start.sh"]