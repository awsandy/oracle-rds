aws rds create-db-instance \
    --db-instance-identifier test-mysql-instance \
    --db-instance-class db.t3.micro \
    --engine oracle \
    --master-username admin \
    --master-user-password secret99 \
    --allocated-storage 20




aws rds create-db-instance --db-name psdmo --dbinstanceidentifier psdmo --db-instance-class db.t2.medium -
engine oracle-se2 --master-username PeopleSoftAdmin --
masteruser-password ******* --vpc-security-group-ids sg-******5a
--db-subnet-group-name peoplesoft-demo-subnetgroup 
--dbparameter-group-name peoplesoft-demo-paramgroup 
--port 1521 --multi-az --engine-version 12.1.0.2.v6 
--licensemodel license-included --option-group-name peoplesoftdemo-og 
--character-set-name WE8ISO8859P15 --no-publicly-


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