#!/bin/bash

sed -i "s/RUN_OPENSIPS=no/RUN_OPENSIPS=yes/g" /etc/default/opensips
sed -i "s/DAEMON=\/sbin\/opensips/DAEMON=\/usr\/sbin\/opensips/g" /etc/init.d/opensips

HOST_IP=$(ip route get 8.8.8.8 | head -n +1 | tr -s " " | cut -d " " -f 7)
sed -i "s/^listen=udp.*5060/listen=udp:${HOST_IP}:5060/g" /etc/opensips/opensips.cfg

sed -i "s/sip:keepalive@127.0.0.1/sip:keepalive@${HOST_IP}/g" /etc/opensips/opensips.cfg

sed -i "s/udp:127.0.0.1:8080/udp:${HOST_IP}:8080/g" /etc/opensips/opensips.cfg

sed -i "s/MYSQL_USER/${DB_USER}/" /etc/opensips/opensips.cfg
sed -i "s/MYSQL_PASSWORD/${DB_PASS}/" /etc/opensips/opensips.cfg
sed -i "s/MYSQL_DATABASE_NAME/${DB_NAME}/" /etc/opensips/opensips.cfg
sed -i "s/MYSQL_DATABASE_HOST/${DB_SERVER}/" /etc/opensips/opensips.cfg

# Set correct domain in the database
DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install mysql-client
mysql -u $DB_USER -h $DB_SERVER -p${DB_PASS} $DB_NAME -e "UPDATE location SET domain='${HOST_IP}'"
# skip syslog and run opensips at stderr
/usr/sbin/opensips -FE
