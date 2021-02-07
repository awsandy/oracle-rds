# Oracle Settings
echo "dbinstall 1 start"
date
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_HOSTNAME=oracle.local
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/19.3.0/dbhome_1
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=orcl
export PDB_NAME=plorcl
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
echo "export ORACLE_SID=orcl" >> ~/.bash_profile
echo "export PDB_NAME=plorcl" >> ~/.bash_profile
echo "export DATA_DIR=/u02/oradata" >> ~/.bash_profile
echo "export PATH=/usr/sbin:/usr/local/bin:${PATH}" >> ~/.bash_profile
echo "export PATH=${ORACLE_HOME}/bin:${PATH}" >> ~/.bash_profile
echo "export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:/lib:/usr/lib" >> ~/.bash_profile
echo "export CLASSPATH=${ORACLE_HOME}/jlib:${ORACLE_HOME}/rdbms/jlib" >> ~/.bash_profile
echo "export _JAVA_OPTIONS='-Dsun.java2d.xrender=false  -Dawt.useSystemAAFontSettings=none'" >> ~/.bash_profile
. ~/.bash_profile
echo "env done"
cd $ORACLE_HOME
pwd
cd /u01/app/oracle/product/19.3.0/dbhome_1
pwd
echo "unzip starting"
date 
unzip -oqq /software/19c.zip
echo "unzipped"
date
export _JAVA_OPTIONS='-Dsun.java2d.xrender=false -Dawt.useSystemAAFontSettings=none'
echo "starting Oralce runInstaller install"
#./runInstaller -executePrereqs -silent -responseFile /software/oracle-rds/db_install_swonly.rsp 
./runInstaller -silent -ignorePrereqFailure -responseFile /software/oracle-rds/db_install_swonly.rsp
if [ $? -ne 0 ]; then
    echo "runInstaller non-zero exit code ?$"
fi
echo "runInstaller complete"
date 
which sqlplus > /dev/null
if [ $? -eq 0 ]; then
    echo "*** sqlplus verified *** "
fi
echo "dbinstall 1 done"
date