bin/charbench -c ../configs/myconfig-ha+rr.xml -a -v users,tpm,tps,resp,dml,trem -rt 0:10 -r rha2.xml
grep AverageTr bin/rha2.xml
grep TotalC bin/rha2.xml