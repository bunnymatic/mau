#!/usr/bin/env bash
SRCDIR = /projects/MAU/trunk
DESTDIR = /home/maudev
EXCLUDES = /home/maudev/deploy.tar.exc
# get the source
cd $SRCDIR && svn up
tar -C $SRCDIR -X $EXCLUDES -cpf - . | tar -C $DESTDIR -xpvf - .

#restart the apache
sudo -u www /etc/init.d/httpd reload

