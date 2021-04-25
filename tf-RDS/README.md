Creation times
oewizard size 1 - 4m09 - m5.large 20GB   14300 free
4 users 49092/866
8 users 54796/973
16 users 49900/866


## cganhe to muti-instance 24min
11:30 Modifying to multi-instance (sync)
11:54 conversion complete

4 users 42000/730
8 users 48496/850   ~14ms av.

### Multi instance failover - 3m
12:16 Failover: (make sure using dns name from connections in RDS)
mydatabase.cg53us8ugnc1.eu-west-1.rds.amazonaws.com   eu-west-1a
actions reboot - reboot with failover
rebooting...
12:16:15 txs drop to zero
see RDS log output for failover complete ~ 3m later
stop and reconnect swingbench
12:19 finshed



12:36 - start manual snap - circa 50s slow down in tx's
12:46 - finished db backup

### Read Replica (90 minutes !)
13:11 - created read replica (15min ? ) - under load   14:35 open read only
mydatabase-rrep1.cg53us8ugnc1.eu-west-1.rds.amazonaws.com
13:31 - all users logged off
with 1x read replica

### Chanage Instance type (20 min)
13:57:40 - chnage to m5.xlarge
14:06 - cnx dropped
14:07 - started db failover
14:10 - fo completed, db modified by cust, db restarted
14:16 - finsihed modifying

8 users: 8 users 88496/1600   ~14ms av.
12 users: 8 users 90,000/1700   ~14ms av.

(burst balance -10% every 7 minutes !) 70m out

write iops 1600

with read replica ready
12 users: 8 users 90,000/1700   ~14ms av.


Split
Read - browse products/orders


## 10GB database tests
8 users 78,000 tpm


8 users 56,000 tpm



Read rep: 
12:30 start backup
12:45 finished backup

