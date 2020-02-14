FROM openresty/openresty:centos

LABEL maintainer="hanxi <hanxi.info@gmail.com>"

RUN yum install -y mysql
RUN yum install -y libuuid-devel
RUN /usr/local/openresty/bin/opm get sumory/lor

ADD . /orchina
WORKDIR /orchina

ADD ./init.sh /
RUN chmod +x /init.sh

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

