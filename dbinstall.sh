# Oracle Settings
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_HOSTNAME=oracle.local
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=cdb1
export PDB_NAME=pdb1
export DATA_DIR=/u02/oradata
export PATH=/usr/sbin:/usr/local/bin:${PATH}
export PATH=$ORACLE_HOME/bin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

echo "export TMP=/tmp" >> ~/.bash_profile
echo "export TMPDIR=${TMP}" >> ~/.bash_profile
echo "export ORACLE_HOSTNAME=oracle.local" >> ~/.bash_profile
echo "export ORACLE_UNQNAME=cdb1" >> ~/.bash_profile
echo "export ORACLE_BASE=/u01/app/oracle" >> ~/.bash_profile
echo "export ORACLE_HOME=${ORACLE_BASE}/product/19.3.0/dbhome_1" >> ~/.bash_profile
echo "export ORA_INVENTORY=/u01/app/oraInventory" >> ~/.bash_profile
echo "export ORACLE_SID=cdb1" >> ~/.bash_profile
echo "export PDB_NAME=pdb1" >> ~/.bash_profile
echo "export DATA_DIR=/u02/oradata" >> ~/.bash_profile
echo "export PATH=/usr/sbin:/usr/local/bin:${PATH}" >> ~/.bash_profile
echo "export PATH=${ORACLE_HOME}/bin:${PATH}" >> ~/.bash_profile
echo "export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib" >> ~/.bash_profile
echo "export CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib" >> ~/.bash_profile
echo "export _JAVA_OPTIONS='-Dsun.java2d.xrender=false  -Dawt.useSystemAAFontSettings=none'" >> ~/.bash_profile
. ~/.bash_profile
echo "env done" >> ~/dbinstall.txt
cd $ORACLE_HOME
pwd >> ~/dbinstall.txt
cd /u01/app/oracle/product/19.3.0/dbhome_1
pwd >> ~/dbinstall.txt
echo "unzip starting" >> ~/dbinstall.txt
date >> /tmp/myinstall.log
unzip -oqq /software/19c.zip
echo "unzipped" >> ~/dbinstall.txt
date >> /tmp/myinstall.log
export _JAVA_OPTIONS='-Dsun.java2d.xrender=false -Dawt.useSystemAAFontSettings=none'
echo "starting install" >> ~/dbinstall.txt
#./runInstaller -executePrereqs -silent -responseFile /software/db_install.rsp 
#./runInstaller -silent -ignorePrereqFailure -responseFile /software/db_install.rsp >> ~/dbinstall.txt
echo "install complete" >> ~/dbinstall.txt
date >> /tmp/myinstall.log
cd ~
unzip -qq /software/swingbenchlatest.zip
cd swingbench/bin


echo "listener" >> ~/dbinstall.txt
#lsnrctl start
echo "dbinstall done" >> ~/dbinstall.txt