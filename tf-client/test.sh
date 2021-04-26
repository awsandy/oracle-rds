pubdns=$(terraform output public_dns | grep amazon | tr -d '"' | tr -d ',' | tr -d ' ')
nmap $pubdns -Pn -p 3389 | grep 3389

