bin/charbench -c ../configs/myconfig-single.xml -a -v users,tpm,tps,resp,dml,trem -rt 0:10 -r rsingle.xml
grep AverageTr bin/rsingle.xml
grep TotalC bin/rsingle.xml