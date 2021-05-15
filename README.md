***bash_profile*** :: Automated reconnaissance wrapper - collecting juicy data & vulnerable testing
```bash
# Dependencies --> go binaries :: https://github.com/missme3f/bin
sudomy(bash), comb(go), cf-check(go), CORS-Scanner(go), dalfox(go), dnsprobe(go), ffuf(go), 
gowitness(go), gron(go), gau(go), gf(go), gospider(go), httpx(go), hakcheckurl(go), naabu(go), 
nuclei(go), meg(go), subjack(go), s3enum(go), secretz(go), unfurl(go), webanalyze(go), kxss(go),   
arjun(py), dsss(py), dnsgen(py), favfreak(py), tplmap(py), js-beautify(py), smuggler(py), linkfinder(py), 
wscat(npm), retire.js(npm)

# Add ons
apkurlgrep(go), clickjacking-poc(go), fdns(go), gitleaks(go), go-dork(go), gobuster(go), httprobe(go),
metabigor(go), qsreplace(go)
```
```bash
# installer.sh (Kali Linux 2019.4) --> Use this script to installing all dependencies
cd resource; chmod +x installer.sh; ./installer.sh 

# Reload .bashrc & .bash_profile after finishing installation
export GOPATH=$HOME/go GOROOT=/usr/local/go-1.13 PATH=$PATH:$GOROOT/bin:$GOPATH/bin
source ~/.bashrc ~/.bash_profile 
```


## Reconnaissance & Collecting Juicy Data 
```bash
# automate-recon <target.com>
# automate-dnsgen <target.com>
# automate-portscan <target.com>
# automate-download <target.com>
------------------------------------------------------------------------------------------------
- subdomain.out         -- Subdomain list               < $target
- virtualhost.out       -- Subdomain [vhost]            < subdomain.out 
- ipresolv.out          -- IP resolved list             < subdomain.out
- cf-ipresolv.out       -- Cloudflare scan              < ipresolv.out 
- httpx-raws.out        -- Probing + statuscode         < subdomain.out 
- httpx.out             -- Subdomain live [80,443]      < httpx-raws.out 
- httpx-9999.out        -- Subdomain live [8000-9999]   < unique httpx.out::subdomain.out
- openport.out          -- Active port scanning [full]  < cf-ipresolv.out
- webanalyzes.out       -- Webanalyzer scan             < httpx.out
- gowitness.html        -- Screenshoting report         < subdomain.out 
- dnsgen.out            -- Subdomain alt+perm           < subdomain.out 
------------------------------------------------------------------------------------------------
- ./raws/data-gau                    -- List uri from gau + removing junk uri
- ./raws/data-gospider               -- List uri from gospider [url] + removing junk uri 
- ./raws/allurls                     -- data-gospider + data-gau
- ./raws/subdomain-resolved          -- Subdomain resolvable [A,AAAA,CNAME]
------------------------------------------------------------------------------------------------
- ./juicyfiles/jsfiles               -- All JS files :: gau + gospider result
- ./juicyfiles/jsfiles2              -- Extract JS files < ./juicyfiles/jsfile + otherjuicyfile 
- ./juicyfiles/node_module           -- Extract JS files < /node_modules/
- ./juicyfiles/otherfiles            -- All other juicyfiles [json,toml,etc] :: gau + gospider
- ./juicyfiles/travislog             -- Fetched Travis build log
- ./juicyfiles/download/js/          -- download < ./juicyfiles/jsfiles     --force-dir + minify
- ./juicyfiles/download/js2/         -- download < ./juicyfiles/jsfiles2    --force-dir + minify
- ./juicyfiles/download/node_module/ -- download < ./juicyfiles/node_module --force-dir + minify
- ./juicyfiles/download/other/       -- download < ./juicyfiles/otherfiles  --force-dir
------------------------------------------------------------------------------------------------
- ./interest/faviconhash             -- Favicon hash checking         < cf-ipresolv + httpx.out 
- ./interest/variablefromjs          -- Interest variable from js     < ./juicyfiles/download/js*
- ./interest/querystrings-keys       -- List querystrings + keys      < ./raws/allurls
- ./interest/interesturi-allurls     -- Interest path [/api,etc]      < ./raws/allurls
- ./interest/interesturi-js          -- Interest path [/api,etc]      < ./raws/data-gospider 
- ./interest/paramsuniq              -- Unique parameter list [live]  < ./raws/allurls
- ./interest/passingparams           -- Passing parameter list        < ./raws/allurls
- ./interest/pathuri                 -- Extract Path only <brute>     < ./raws/allurls
- ./interest/paramsuri               -- Extract params only <brute>   < ./interest/paramsuniq
------------------------------------------------------------------------------------------------
- ./fuzz/fuzz-fileinclusion          -- gf fileinclusion pattern      < ./interest/paramsuniq
- ./fuzz/fuzz-openredirect           -- gf redirect pattern           < ./interest/paramsuniq
- ./fuzz/fuzz-rce                    -- gf rce pattern                < ./interest/paramsuniq
- ./fuzz/fuzz-idor                   -- gf idor pattern               < ./interest/paramsuniq
- ./fuzz/fuzz-sqli                   -- gf sqli pattern               < ./interest/paramsuniq
- ./fuzz/fuzz-ssrf                   -- gf ssrf pattern               < ./interest/paramsuniq
- ./fuzz/fuzz-ssti                   -- gf ssti pattern               < ./interest/paramsuniq
------------------------------------------------------------------------------------------------
- ./wordlist/parameter               -- Generate params wordlist      < ./raws/allurls
- ./wordlist/paths                   -- Generate paths wordlist       < ./raws/allurls * js
- ./wordlist/js-variable             -- Collecting var                < ./juicyfiles/download/js*


# Favicon Hash Fingerprint
99395752    : 'slack-instance'
878647854   : 'atlasian'
116323821   : 'spring-boot'     --> Spring Boot Actuator (jolokia XXE/RCE)
```


## Parameter & Path Discovery (Brute)
```bash
# automate-brute <target.com>
------------------------------------------------------------------------------------------------
1. Juicy Path & Endpoint Bruteforce
   --> ./brute/internalpath     # /resource/wordlist/dir/internalpath.txt   <-- virtualhost.out
   --> ./brute/bigwordlist      # /resource/wordlist/dir/big-wordlist.txt   <-- ./interest/pathuri
   --> ./brute/sortwordlist     # /resource/wordlist/dir/short-wordlist.txt <-- ./interest/pathuri
   --> ./brute/springboot       # /resource/wordlist/dir/spring-boot.txt    <-- ./interest/pathuri
2. Parameter discovery (bruteforce)
   <-- ./interest/paramsuri
   --- ./brute/parameter1       # ./wordlist/parameter 
   --> ./brute/parameter2       # /resource/wordlist/parameter 
```

## Vulnerable Testing
```bash
# automate-testing <target.com>
# automate-s3discovery <target.com>
------------------------------------------------------------------------------------------------
1.  Hardcoded Sensitive Data Exposure -- Scanning download juicy files 
    <-- ./juicyfiles/download
    --> ./automationtesting/sensitivedata-generic
    --> ./automationtesting/sensitivedata
2.  S3 bucket discovery
    <-- ./raws/data-gospider + ./juicyfiles/*
    <-- /root/resource/wordlist/s3 :: ./wordlist/s3bucketnames
    --> ./automationtesting/s3bucket-all
    --> ./automationtesting/s3bucket-brute 
3.  Subdomain takeover
    <-- subdomain.out
    --> ./automationtesting/takeover-nxdomain
    --> ./automationtesting/takeover-subjack
4.  CVEs/Advisories
    <-- httpx.out
    --> ./automationtesting/RCE-Jolokia
    --> ./automationtesting/CVE-2020-5410       # Directory Traversal in Spring Cloud Config Server
    --> ./automationtesting/CVE-2018-1000129    # Jolokia XSS
5.  CORS Misconfig Scan 
    <-- httpx.out
    --> ./automationtesting/cors-vuln
6.  Unrestricted PUT method 
    <-- httpx.out
    --> ./automationtesting/unrestricted-putMethod
7.  Open Redirect > Clickjacking, XSS, SSRF
    <-- httpx.out
    --> ./automationtesting/openredirect-vuln
8.  XSS (Blind, Reflected)
    <-- ./raws/paramsuniq
    --> ./automationtesting/xss-reflected
9.  SSTI > RCE 
    <-- ./fuzz/fuzz-ssti
    --> ./automationtesting/ssti-vuln
10. SQLI Fuzzing (error based)
    <-- ./fuzz/fuzz-sqli
    --> ./automationtesting/sqli-vuln
11. File Inclusion
    <-- ./fuzz/fuzz-fileinclusion
    --> ./automationtesting/fileinclusion-vuln
12. HTTP Request Smuggling / Desync
    <-- httpx.out
    --> ./automationtesting/httpsmuggler-vuln
XX. Other 
    --> Command injection
    --> Host Header Injection (x-forwarded-host) > Open Redirect
    --> CRLF Injection > XSS, Cache-Poisoning
    --> Custom nuclei Pattern : New CVE&advisores, etc
    --> Dependencies vulnerability checking (SCA)
    --> SAST
```

## Hardcoded/Sensitive Data Regex Pattern
| Platform              | Key Type              | Regular Expression                                                           |
|-----------------------|--------------------   |----------------------------------------------------------------------------  |
| ***Generic credential***    | Password, Token, etc  | "[0-9a-zA-Z*-_/]{20,80}"                                               |
| Private Key           | RSA, DSA, EC, PGP     | "---(BEGIN|END)"                                                             |
| Amazon MWS            | Auth Token            | "amzn\\.mws\\.[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}"  |
| AWS                   | Access Key ID         | "AKIA[0-9A-Z]{16}"                                                           |
|                       | Secret Access Key     | ***(Generic Credential)*** "[0-9a-zA-Z*-_/+]{20,80}"                         |
| Bitly                 | OAuth Access Token    | ***(Generic Credential)***                                                   |
| CircleCI              | Access Token          | ***(Generic Credential)*** "[0-9a-f]{40}"                                    |
| Facebook              | OAuth Access Token    | ***(Generic Credential)*** "[A-Za-z0-9]{125}"                                |
| Gitlab                | Auth Token            | ***(Generic Credential)***                                                   |
| Github                | OAuth Access Token    | ***(Generic Credential)*** "[0-9a-zA-Z]{35,40}"                              |
| Google                | API Key               | "AIza[0-9A-Za-z*]{35}"                                                       |
|                       | OAuth Access Token    | "ya29\\.[0-9A-Za-z*]+"                                                       |
| Instagram             | OAuth Access Token    | "[0-9a-fA-F]{7}\\.[0-9a-fA-F]{32}"                                           |
| MailChimp             | API Key               | "[0-9a-f]{32}-us[0-9]{1,2}"                                                  |
| Mailgun               | API Key               | "key-[0-9a-zA-Z]{32}"                                                        |
| NPM                   | Auth Token            | "[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}"               |
| PayPal Braintree      | OAuth Access Token    | "access_token\\$production\\$[0-9a-z]{16}\\$[0-9a-f]{32}"                    |
| Picatic               | API Key               | "sk_live_[0-9a-z]{32}"                                                       |
| Slack                 | OAuth Access Token    | "key-[0-9a-zA-Z]{32}"                                                        |
| SendGird              | API Key               | "SG\\.[a-zA-Z0-9]{22}\\.[a-zA-Z0-9*-_]{43}"                                  |
| Stripe                | API Key               | "sk_live_[0-9a-zA-Z]{24}"                                                    |
|                       | Restricted API Key    | "rk_live_[0-9a-zA-Z]{24}"                                                    |
| Square                | Access Token          | "sq0atp-[0-9A-Za-z*]{22}"                                                    |
|                       | OAuth Secret          | "sq0csp-[0-9A-Za-z*]{43}"                                                    |
| Twilio                | Account/App SID       | "(AC|AP)[a-zA-Z0-9]{32}"                                                     |
|                       | API Key SID           | "SK[0-9a-fA-F]{32}"                                                          |
| Travis CI             | Auth Token            | ***(Generic Credential)***                                                   |



```bash
Todo
# Firebase Custom Token and API key
# Google Cloud Messaging Key
# Hubspot API key
# Dropbox API Bearer/Auth Token
# Microsoft Azure Client ID, secret & Tenant ID
# Mapbox API key 
# Jumpcloud API key
# Salesforce API Key/Bearer Token 
# WPEngine API key & Account Name
# DataDog API Key & Application Key
# Gitlab Personal/Private Token
# Paypal ClientID & Secret
```

## Bug Bounty Tools
| Type              | Tool              | Description                                                         |
|-------------------|-------------------|---------------------------------------------------------------------|
| **Army-Knife/SCAN**   | [jaeles](https://github.com/jaeles-project/jaeles)    | The Swiss Army knife for automated Web Application Testing  |
| **Fetch/PROBE**       | [hakcheckurl](https://github.com/hakluke/hakcheckurl) | Takes a list of URLs and returns their HTTP response codes  |
| **Fetch/PROBE**       | [httpx](https://github.com/projectdiscovery/httpx)   | Fast and multi-purpose HTTP toolkit allow to run multiple probers using retryablehttp library |
| **Fetch/PATH**        | [meg](https://github.com/tomnomnom/meg)               | Fetch many paths for many hosts - without killing the hosts   |
| **Recon/CF**          | [cf-check](https://github.com/dwisiswant0/cf-check)   | Cloudflare Checker written in Go  |
| **Recon/CRAWL**       | [gospider](https://github.com/jaeles-project/gospider)| Gospider - Fast web spider written in Go                           |
| **Recon/DOMAIN**      | [sudomy](https://github.com/Screetsec/Sudomy)         | Sudomy is a subdomain enumeration tool to collect subdomains and analyzing domains performing automated reconnaissance (recon) for bug hunting / pentesting                          |
| **Recon/DNS**         | [dnsprobe](https://github.com/projectdiscovery/dnsprobe)| DNSProb is a tool built on top of retryabledns that allows you to perform multiple dns queries of your choice with a list of user supplied resolvers.   |
| **Recon/DNS**         | [hakrevdns](https://github.com/hakluke/hakrevdns)     | Small, fast tool for performing reverse DNS lookups en masse. |
| **Recon/DNS**         | [shuffledns](https://github.com/projectdiscovery/shuffledns)    | shuffleDNS is a wrapper around massdns written in go that allows you to enumerate valid subdomains using active bruteforce as well as resolve subdomains with wildcard handling and easy input-output support. |
| **Recon/DNS**         | [altdns](https://github.com/infosec-au/altdns)        | Generates permutations, alterations and mutations of subdomains and then resolves them |
| **Recon/DNS**         | [dnsgen](https://github.com/ProjectAnte/dnsgen)        | Generates combination of domain names from the provided input. |
| **Recon/FAVICON**     | [FavFreak](https://github.com/devanshbatham/FavFreak) | Making Favicon.ico based Recon Great again !  |
| **Recon/PORT**        | [naabu](https://github.com/projectdiscovery/naabu)    | A fast port scanner written in go with focus on reliability and simplicity.  |
| **Recon/WEBANLYZE**   | [webanalyze](https://github.com/rverton/webanalyze)   | Port of Wappalyzer (uncovers technologies used on websites) in Go to automate scanning.  |
| **Recon/WVS**         | [nuclei](https://github.com/projectdiscovery/nuclei)  | Nuclei is a fast tool for configurable targeted scanning based on templates offering massive extensibility and ease of use.  |
| **Recon/URLS**        | [gau](https://github.com/lc/gau)                      | Fetch known URLs from AlienVault's Open Threat Exchange, the Wayback Machine, and Common Crawl.  |
| **Scanner/FUZZ**      | [ffuf](https://github.com/ffuf/ffuf)                  |  Fast web fuzzer written in Go|
| **Scanner/FUZZ**      | [Arjun](https://github.com/s0md3v/Arjun)              | HTTP parameter discovery suite. | 
| **Scanner/TKOVER**    | [subjack](https://github.com/haccer/subjack)          | Subdomain Takeover tool written in Go |
| **Scanner/CORS**      | [CORS-Scanner ](https://github.com/Tanmay-N/CORS-Scanner)  | CORS-Scanner is written in go, designed to discover CORS misconfigurations vulnerabilities of web application. |
| **Scanner/DESYNC**    | [smuggler](https://github.com/defparam/smuggler)      | An HTTP Request Smuggling / Desync testing tool written in Python 3 |
| **Scanner/SSTI**      | [tplmap](https://github.com/epinna/tplmap)            | Server-Side Template Injection and Code Injection Detection and Exploitation Tool  |
| **Scanner/SSRF**      | [SSRFmap](https://github.com/swisskyrepo/SSRFmap)     | Automatic SSRF fuzzer and exploitation tool |
| **Scanner/SQLI**      | [DSSS](https://github.com/stamparm/DSSS)              | Damn Small SQLi Scanner  |
| **Scanner/SQLI**      | [Atlas](https://github.com/m4ll0k/Atlas)              | Quick SQLMap Tamper Suggester  |
| **Scanner/SQL**       | [sqlmap](https://github.com/sqlmapproject/sqlmap)     | Automatic SQL injection and database takeover tool |
| **Scanner/SCA**       | [retire.js ](https://github.com/retirejs/retire.js/)  | Scanner detecting the use of JavaScript libraries with known vulnerabilities  |
| **Scanner/S3**        | [S3Scanner](https://github.com/sa7mon/S3Scanner)      | Scan for open AWS S3 buckets and dump the contents |
| **Scanner/XSS**       | [dalfox](https://github.com/hahwul/dalfox)            | DalFox(Finder Of XSS) / Parameter Analysis and XSS Scanning tool based on golang |
| **Scanner/XSS**       | [kxss](https://github.com/tomnomnom/hacks/tree/master/kxss)    | XSS Reflection scanner |
| **Scanner/XSS**       | [XSStrike](https://github.com/s0md3v/XSStrike)        | Most advanced XSS scanner. | 
| **Utility/CALLBACK**  | [dnsobserver](https://github.com/allyomalley/dnsobserver) | A handy DNS service written in Go to aid in the detection of several types of blind vulnerabilities. It monitors a pentester's server for out-of-band DNS interactions and sends lookup notifications via Slack. |
| **Utility/COMBINE**   | [comb](https://github.com/tomnomnom/hacks/tree/master/comb)    | Combine the lines from two files in every combination. |
| **Utility/FLOW**      | [SequenceDiagram](https://sequencediagram.org)        | Online tool for creating UML sequence diagrams |
| **Utility/ENV**       | [axiom](https://github.com/pry0cc/axiom)              | A dynamic infrastructure toolkit for red teamers and bug bounty hunters! |
| **Utility/SCRNSHOT**  | [gowitness](https://github.com/sensepost/gowitness)   | mag gowitness - a golang, web screenshot utility using Chrome Headless  |
| **Utility/GREP**      | [gf](https://github.com/tomnomnom/gf)                 | A wrapper around grep, to help you grep for things |
| **Utility/JSON**      | [gron](https://github.com/tomnomnom/gron)             | Make JSON greppable! | 
| **Utility/JSPARSER**  | [LinkFinder](https://github.com/GerbenJavado/LinkFinder)    | A python script that finds endpoints in JavaScript files  |
| **Utility/MINIFY**    | [js-beautify](https://github.com/beautify-web/js-beautify)    |  Beautifier for javascript  |
| **Utility/URLPARSER** | [unfurl](https://github.com/tomnomnom/unfurl)         | Pull out bits of URLs provided on stdin  |
| **Utility/TEMPLATE**  | [bountyplz](https://github.com/fransr/bountyplz)      | Automated security reporting from markdown templates (HackerOne and Bugcrowd are currently the platforms supported) |
| **Utility/VULN**      | [Gopherus](https://github.com/tarunkant/Gopherus)     | This tool generates gopher link for exploiting SSRF and gaining RCE in various servers | 
| **Utility/VULN**      | [oxml_xxe](https://github.com/BuffaloWill/oxml_xxe)   | A tool for embedding XXE/XML exploits into different filetypes | 
| **Utility/VULN**      | [postMessage-tracker](https://github.com/fransr/postMessage-tracker) | A Chrome Extension to track postMessage usage (url, domain and stack) both by logging using CORS and also visually as an extension-icon |
| **Utility/VULN**      | [s3-bucket-list](https://addons.mozilla.org/en-US/firefox/addon/s3-bucket-list/) | A Chrome Extension to Finds Amazon S3 Buckets while browsing then records it in the add-on content. |
| **Utility/KEYHACK**   | [keyhacks](https://github.com/streaak/keyhacks) | Repository which shows quick ways in which API keys leaked by a bug bounty program can be checked to see if they're valid.  |
| **Utility/KEYHACK**   | [AdvancedKeyHacks](https://github.com/udit-thakkur/AdvancedKeyHacks) | API Key/Token Exploitation Made easy.  |
| **List/PAYLOAD**      | [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) | A list of useful payloads and bypass for Web Application Security and Pentest/CTF |
| **List/WORDLIST**     | [SecLists](https://github.com/danielmiessler/SecLists) | SecLists is the security tester's companion. It's a collection of multiple types of lists used during security assessments, collected in one place. List types include usernames, passwords, URLs, sensitive data patterns, fuzzing payloads, web shells, and many more. |
| **List/WORDLIST**     | [CT_subdomains](https://github.com/internetwache/CT_subdomains) | An hourly updated list of subdomains gathered from certificate transparency logs |
| **Discovery/S3**   | [s3enum](https://github.com/koenrh/s3enum) |  Fast Amazon S3 bucket enumeration tool for pentesters. 
| **Discovery/CICD** | [secretz](https://github.com/lc/secretz) |  secretz, minimizing the large attack surface of Travis CI  | 
| **Discovery/GIT** | [gitGraber](https://github.com/hisxo/gitGraber) | Monitor GitHub to search and find sensitive data | 
| **Discovery/GIT** | [truffleHog](https://github.com/dxa4481/truffleHog) | Searches through git repositories for high entropy strings and secrets, digging deep into commit history | 
| Discovery/GQL | [graphql-voyager](https://github.com/APIs-guru/graphql-voyager) | 🛰️ Represent any GraphQL API as an interactive graph | 
| Discovery/GQL | [inql](https://github.com/doyensec/inql) | InQL - A Burp Extension for GraphQL Security Testing | 
| Scanner/GQL   | [GraphQLmap](https://github.com/swisskyrepo/GraphQLmap) | GraphQLmap is a scripting engine to interact with a graphql endpoint for pentesting purposes. | 
| Scanner/NOSQL | [NoSQLMap](https://github.com/codingo/NoSQLMap) | Automated NoSQL database enumeration and web application exploitation tool. | 
