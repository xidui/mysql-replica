FROM ubuntu:14.04

RUN apt-get update \
  && echo mysql-server mysql-server/root_password password your_pass | debconf-set-selections \
  && echo mysql-server mysql-server/root_password_again password your_pass | debconf-set-selections \
  && apt-get -y install mysql-server

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mysqld"]
