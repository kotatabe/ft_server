# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Dockerfile                                         :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: kotatabe <kotatabe@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2020/11/16 16:09:02 by kotatabe          #+#    #+#              #
#    Updated: 2020/11/19 19:16:04 by kotatabe         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

FROM debian:buster

RUN  apt-get update -y
RUN	 apt-get install -y \
 	 nginx \
	 mariadb-server \
	 mariadb-client \
	 php-cgi \
	 php-fpm \
	 php-mysql \
	 php-common \
	 php-pear \
	 php-mbstring \
	 php-zip \
	 php-net-socket \
	 php-gd \
	 php-xml-util \
	 php-gettext \
	 php-bcmath \ 
	 supervisor \
	 unzip \
	 vim \
	 wget

# wordpress & phpmyadmin
WORKDIR	/var/www/html
RUN  wget https://wordpress.org/latest.tar.gz \
	 && tar -xvzf latest.tar.gz \
	 && rm /var/www/html/latest.tar.gz \
	 \
	 && wget -O phpmyadmin.tar.gz https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.gz \
	 && tar -xvzf phpmyadmin.tar.gz \
	 && mv phpMyAdmin-5.0.2-all-languages phpmyadmin \
	 && rm phpmyadmin.tar.gz


COPY ./srcs/wp-config.php /var/www/html/wordpress
RUN  chown -R www-data:www-data /var/www/html/


# mysql
COPY ./srcs/mysql.sql /var/
RUN  service mysql start && mysql -u root < /var/mysql.sql

# ssl
RUN	mkdir -p /etc/nginx/ssl \
		\
	&& openssl genrsa \
		-out /etc/nginx/ssl/private.key 2048 \
		\
	&& openssl req -new \
		-key /etc/nginx/ssl/private.key \
		-out /etc/nginx/ssl/server.csr \
		-subj "/C=JP/ST=Tokyo/L=Roppongi/O=42tokyo/CN=ktabe" \
		\
	&& openssl x509 -req \
		-days 365 \
		-signkey /etc/nginx/ssl/private.key \
		-in /etc/nginx/ssl/server.csr \
		-out /etc/nginx/ssl/server.crt

# supervisor
COPY ./srcs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN  chmod +x /etc/supervisor/conf.d/supervisord.conf

# Entrykit
RUN wget -O entrykit.tgz https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz \
	&& tar -xvzf entrykit.tgz \
	&& rm entrykit.tgz \
	&& mv entrykit /bin/entrykit \
	&& chmod +x /bin/entrykit \
	&& entrykit --symlink

COPY ./srcs/default.tmpl /etc/nginx/sites-available/default.tmpl

ENTRYPOINT ["render", "/etc/nginx/sites-available/default", "--", "/usr/bin/supervisord"]
