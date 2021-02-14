 aws rds create-db-instance \
  --db-instance-identifier mydbinstance \
  --db-name MYDB \
  --allocated-storage 20 \
  --storage-type gp2 \
  --db-instance-class db.m5.xlarge \
  --engine oracle-ee  \
  --port 1521 \
  --backup-retention-period 1 \
  --license-model byol \
  --master-user-password fjie87bna09bfe3 \
  --master-username admin \
  --engine-version 19.0.0.0.ru-2020-01.rur-2020-01.r1


aws rds create-db-instance \
 --db-instance-identifier $USER-ee-test-12102v14 \
 --db-name ORCL \
 --allocated-storage 20 \
 --storage-type gp2 \
 --db-instance-class db.r5.xlarge \
 --engine oracle-ee \
 --port 1521 \
 --backup-retention-period 0 \
 --license-model=byol \
 --master-user-password fjie87bna09bfe3 \
 --master-username admin \
 --engine-version 12.1.0.2.v14 






