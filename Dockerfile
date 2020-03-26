FROM ubuntu:latest
MAINTAINER Sergio Gómez <sergio@quaip.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt update -y
RUN apt -y upgrade
 
# Basic Requirements
RUN apt -y install mysql-server mysql-client pwgen python-setuptools curl git unzip python-pip
# Easy_install
# RUN pip install supervisor

# Moodle Requirements
RUN apt -y install apache2 php php7.2-gd libapache2-mod-php postfix wget supervisor php7.2-pgsql vim curl libcurl4 libcurl4-openssl-dev php7.2-curl php7.2-xmlrpc php7.2-intl php7.2-mysql php7.2-mbstring php7.2-intl php7.2-xmlrpc php7.2-ldap php7.2-pspell php7.2-xml php7.2-zip php7.2-soap

# SSH
RUN apt -y install openssh-server
RUN mkdir -p /var/run/sshd

# mysql config
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

#RUN easy_install supervisor
RUN pip install supervisor
ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
RUN cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html
RUN chown -R www-data:www-data /var/www/html/moodle
RUN mkdir /var/moodledata
RUN chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata
RUN chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]

