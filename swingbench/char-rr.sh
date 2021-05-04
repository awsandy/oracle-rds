bin/charbench -c ../configs/myconfig-readonly.xml -a -v users,tpm,tps,resp,dml,trem -rt 0:10 -r rro.xml
grep AverageTr bin/rro.xml
grep TotalC bin/rro.xml