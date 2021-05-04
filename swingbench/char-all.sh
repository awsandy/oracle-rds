rm -f bin/r*.xml
bin/charbench -c ../configs/myconfig-single.xml -a -rt 0:20 -r rsingle.xml
bin/charbench -c ../configs/myconfig-ha.xml -a -rt 0:20 -r rha1.xml
bin/charbench -c ../configs/myconfig-ha+rr.xml -a  -rt 0:20 -r rha2.xml &
bin/charbench -c ../configs/myconfig-readonly.xml -a -rt 0:20 -r rro.xml
sleep 120
echo "Single AZ"
grep AverageTr bin/rsingle.xml
grep TotalC bin/rsingle.xml
echo "HA multi AZ"
grep AverageTr bin/rha1.xml
grep TotalC bin/rha1.xml
echo "HA multi AZ with Read Replica"
grep AverageTr bin/rha2.xml
grep TotalC bin/rha2.xml
echo "Read Replica - Warehouse read only"
grep AverageTr bin/rro.xml
grep TotalC bin/rro.xml
