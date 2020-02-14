#!/bin/sh

if [ -z "$PROFILE" ];then
	PROFILE="dev"
fi

mkdir -p logs & mkdir -p tmp
echo "Use profile: "${PROFILE}
nginx -p `pwd`/ -c conf/nginx-${PROFILE}.conf -g 'daemon off;'
