# Redis Cluster - High Availability

_redis [7.0.7] with 3 linux machines | choose higher version if you like_

## redis sentinel - these setups help

1. Redis Installation [skip if already installed]
2. Hostname Resolution [or we can skip this by IP address]
3. Redis Configuration
4. Redis Cluster Initialization

![RedisCluster](./helpers/redis.png)

### 1. Redis Installation

---

_Here we are refering the linux machine to install redis. To install [refer here](https://redis.io/docs/getting-started/installation/) or below command on terminal to install_

```
yum -y install redis
```

_Or use [install_redis_stable.sh](./install_redis_stable.sh) file by following cmds to install_

```
# MODIFY THE IPADDRESS AS PER YOUR MACHINE
chmod +x install_redis_stable.sh
./install_redis_stable.sh
```

_if linux machine has firewall service running, we need to enable redis ports by running below command_

```
firewall-cmd --permanent --add-port={6379,16379}/tcp
firewall-cmd --reload
```

_now, let's run redis as a service on linux, and verify the service status_

```
systemctl enable redis
systemctl start redis
systemctl status redis
```

_**REPEAT** the step in Each & Every machine_

### 2. Hostname Resolution

---

_We are setting up redis with 3 linux machine, here we are the ips and their hostname reference as, modify as per your structure_

_Now, let's add hosts as known host for the machine, login to hostname1 machine and run the below command_

```
cat >> /etc/hosts <<EOF
192.168.1.101 hostname1
192.168.1.102 hostname2
192.168.1.103 hostname3
EOF

cat /etc/hosts
```

_**REPEAT** the step in **Each & Every** machine_

### 3. Redis Configuration

---

_Here, we are setting up redis [cluster](https://redis.io/docs/management/scaling/), to start the cluster configuration, we need to setup redis.conf file_

_[linux](https://redis.io/docs/management/config/): /etc/redis.conf_

```
# ...
bind 127.0.0.1 192.168.1.101
# ...
dir /var/lib/redis
# ...
appendonly yes
# ...
appendfsync no      # default as 30 seconds
# ...
requirepass test123 # password
masterauth test123  # password
# ...
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 10000      # 10 seconds
```

_now, restart the service by running_

```
systemctl restart redis
```

_**REPEAT** the step Each & Every node_

_after completing the configuration redis is ready, to verify, login into on of redis node as_

```
redis-cli -c
127.0.0.1:6379> info
#
#    # Cluster
#    cluster-enabled yes
#
```

### 4. Redis Cluster Initialization

---

_Redis Cluster helps to setup clustering between nodes and does the auto failover if master nodes fail_

_We have to initialize the redis cluster once by following the below commands as_

_We need to run commands in one of redis cluster node_

```
redis-cli --cluster create 192.168.1.103:6379 192.168.1.102:6379 192.168.1.101:6379 -a test123
```

_now, restart the service by running_

```
systemctl enable redis
systemctl restart redis
systemctl status redis
```

_**REPEAT** the step in **Each & Every** machine_

_completed :)_

### ADDITIONAL

---

#### A. How to connect with redis-cluster

_To connect with redis, we need to connect with redis cluster as_

`hostname1:6379,hostname2:6379,hostname2:6379`
