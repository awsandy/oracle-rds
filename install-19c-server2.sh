#!/bin/bash
set +x
date
echo "======= Oracle dbinstall 2" 
date 
sudo -u oracle -- sh -c "/software/oracle-rds/dbinstall-2.sh"
echo "======= dbinstall 2 done ....." 
date 
#cat /home/oracle/dbinstall.txt 
echo "======= Finished 19c server 2 install .. at ======== "
date 
