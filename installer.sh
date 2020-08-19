#!/bin/bash
OKGREEN='\033[92m'; RESET='\e[0m'
echo -e "$OKGREEN ++ --------- Installing Dependencies --------- ++ $RESET"

printf '%b\n\n'; echo -e "$OKGREEN Step1 : Adding Kali Repo $RESET"
cp /etc/apt/sources.list /etc/apt/sources.list.bak
echo "deb http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list
echo "deb-src http://http.kali.org/kali kali-rolling main non-free contrib" >> /etc/apt/sources.list
wget https://http.kali.org/pool/main/k/kali-archive-keyring/kali-archive-keyring_2020.2_all.deb -O /tmp/kali-archive-keyring_2020.2_all.deb
apt install /tmp/kali-archive-keyring_2020.2_all.deb -y

# ----------------------------------------------------------------------------------------------------------------------------------------- #
printf '%b\n\n'; echo -e "$OKGREEN Step2 : Repo update + Installing Package $RESET"
apt-get update -y; DEBIAN_FRONTEND=noninteractive apt install -y libc6-dev;
apt-get install -y npm git python3 python-pip git python3-pip parallel jq expect libpq-dev python3-dev nmap build-essential curl wget apache2 \
chromium-browser zip; service apache2 start; 
pip install --upgrade pip; pip3 install --upgrade pip

printf '%b\n\n'; echo -e "$OKGREEN Step3 : Clone resource Repo + Setup Go $RESET"
cd /root; git clone https://missme3f@github.com/missme3f/resource.git resource; cp /root/resource/bash_profile /root/.bash_profile
wget https://dl.google.com/go/go1.13.9.linux-amd64.tar.gz; tar xf go1.13.9.linux-amd64.tar.gz; mv go /usr/local/go-1.13; rm go1.13.9.linux-amd64.tar.gz;

export GOPATH=$HOME/go GOROOT=/usr/local/go-1.13 PATH=$PATH:$GOROOT/bin:$GOPATH/bin
source ~/.bashrc ~/.bash_profile 
mkdir /root/go /root/go/bin /root/tools /var/www/html/automate;

# ----------------------------------------------------------------------------------------------------------------------------------------- #
# binaries tool
printf '%b\n\n'; echo -e "$OKGREEN Step4 : Copying Go Binary Tools $RESET"
git clone https://github.com/missme3f/bin.git bin; cp /root/bin/* /root/go/bin

# sudomy
printf '%b\n\n'; echo -e "$OKGREEN Step5 : Setup sudomy $RESET"
git clone https://github.com/missme3f/Sudomy.git sudomy;
pip install -r ./sudomy/requirements.txt;


# ----------------------------------------------------------------------------------------------------------------------------------------- #
# Installing tools
printf '%b\n\n'; echo -e "$OKGREEN Step6 : Installing tools $RESET"
cd tools;

# gf
wget https://raw.githubusercontent.com/tomnomnom/gf/master/gf-completion.bash
source gf-completion.bash; rm gf-completion.bash;
cp -r /root/resource/gf ~/.gf

# linkfinder
git clone https://github.com/GerbenJavado/LinkFinder.git linkfinder
pip3 install -r ./linkfinder/requirements.txt; 
echo "alias linkfinder=\"python3 /root/tools/linkfinder/linkfinder.py\"" >> /root/.bashrc

# httpx
wget https://github.com/projectdiscovery/httpx/releases/download/v0.0.6/httpx_0.0.6_linux_386.tar.gz
tar -xvf httpx_0.0.6_linux_386.tar.gz; mv httpx /usr/bin/httpx

# FavFreak
git clone https://github.com/devanshbatham/FavFreak.git favfreak
pip3 install -r ./favfreak/requirements.txt; 
echo "alias favfreak=\"python3 /root/tools/favfreak/favfreak.py\"" >> /root/.bashrc

# arjun
git clone https://github.com/s0md3v/Arjun.git arjun
echo "alias arjun=\"python3 /root/tools/arjun/arjun.py\"" >> /root/.bashrc

# dsss
git clone https://github.com/stamparm/DSSS.git;
echo "alias dsss=\"python3 /root/tools/DSSS/dsss.py\"" >> /root/.bashrc

# githubclonner
git clone https://github.com/mazen160/GithubCloner
pip3 install -r ./GithubCloner/requirements.txt; 
echo "alias githubcloner=\"python3 /root/tools/GithubCloner/githubcloner.py\"" >> /root/.bashrc

# smuggler
git clone https://github.com/defparam/smuggler.git
echo "alias smuggler=\"python3 /root/tools/smuggler/smuggler.py\"" >> /root/.bashrc

# tplmap
git clone https://github.com/epinna/tplmap.git
pip install -r ./tplmap/requirements.txt;
echo "alias tplmap=\"python /root/tools/tplmap/tplmap.py\"" >> /root/.bashrc

# js-beautify
pip install jsbeautifier

# wscat
npm install -g wscat

# retire.js
npm install -g retire

# dnsgen
pip3 install dnsgen


# ----------------------------------------------------------------------------------------------------------------------------------------- #
# Installing other tools
printf '%b\n\n'; echo -e "$OKGREEN Step7 : Installing Other tools $RESET"

# gitGrabber
git clone https://github.com/hisxo/gitGraber.git
pip3 install -r ./gitGraber/requirements.txt
echo "alias gitgraber=\"python3 /root/tools/gitGraber/gitGraber.py\"" >> /root/.bashrc

# truffleHog
pip install truffleHog

# ----------------------------------------------------------------------------------------------------------------------------------------- #
printf '%b\n\n\n'; echo -e "$OKGREEN Installation almost done $RESET"

