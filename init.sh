#!/bin/sh

# usage
# docker-compose run orchina /init.sh

# import sql
mysql -h ormysql -u orchina -porchina -D orchina < /orchina/install/blog.sql

# copy avatar
cp /orchina/install/avatar/* /data/openresty-china/static/

