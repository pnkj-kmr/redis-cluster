#!/bin/sh
# TO INSTALL REDIS FROM SOURCE

cd /opt
yum install -y tcl python3 systemd-devel gcc
wget https://download.redis.io/redis-stable.tar.gz
tar -xzvf redis-stable.tar.gz
cd redis-stable/
make BUILD_WITH_SYSTEMD=yes USE_SYSTEMD=yes
make test
make install

redis_server="$(which redis-server)"

rm -rf /var/lib/redis/
mkdir /var/lib/redis
cat > /etc/redis.conf << EOF
bind 127.0.0.1 192.168.1.101
dir /var/lib/redis
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
requirepass test123
masterauth test123
EOF

cat > /etc/systemd/system/redis.service << EOF
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
Type=notify
User=root
Group=root
ExecStart=${redis_server} /etc/redis.conf --supervised systemd
ExecStop=

[Install]
WantedBy=multi-user.target
EOF

systemctl -daemon-reload
service redis start
service redis status
