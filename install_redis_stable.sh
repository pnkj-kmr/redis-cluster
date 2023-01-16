#!/bin/sh
# TO INSTALL REDIS FROM SOURCE

# removing is exists
yum remove -y redis

cd /opt
yum install -y tcl python3 systemd-devel gcc wget tar make
wget https://download.redis.io/redis-stable.tar.gz
rm -rf /opt/redis-stable/
tar -xzvf redis-stable.tar.gz
cd redis-stable/
make BUILD_WITH_SYSTEMD=yes USE_SYSTEMD=yes
make test
make install

redis_server="$(which redis-server)"

rm -rf /var/lib/redis/
mkdir /var/lib/redis
cat > /etc/redis.conf << EOF
bind 127.0.0.1 ${1}
dir /var/lib/redis
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
#appendfsync everysec
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
systemctl enable redis.service
systemctl start redis.service
systemctl status redis.service

