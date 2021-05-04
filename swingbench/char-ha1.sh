bin/charbench -c ../configs/myconfig-ha.xml -a -v users,tpm,tps,resp,dml,trem -rt 0:10 -r rha1.xml
grep AverageTr bin/rha1.xml
grep TotalC bin/rha1.xml