#!/bin/bash

green="\e[32m"
blue="\e[34m"
red="\e[31m"
yellow="\e[33m"
reset="\e[0m"

Target=$1
Mode=$2

httpx_threads=50
httpx_rate=150
ffuf_threads=25
ffuf_delay=0.1
parallel_jobs=5

if [ -z "$Target" ]
then
        echo -e "${red}[-] Usage : ./reconforge.sh domain.com [quick/deep]${reset}"
        exit 1
fi

if [[ ! $Target =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
then
        echo -e "${red}[-] Invalid Domain${reset}"
        exit 1
fi

tools=("subfinder" "assetfinder" "amass" "httpx" "dnsx" "naabu" "ffuf" "katana" "nuclei" "gowitness" "jq" "curl" "xargs")

for tool in "${tools[@]}"
do
        if ! command -v $tool &> /dev/null
        then
                echo -e "${red}[-] $tool not installed${reset}"
                exit 1
        fi
done

if [ ! -d $Target ]
then
        mkdir -p $Target/{subs,probe,ports,content,crawl,nuclei,screenshots,secrets,api,logs,reports,temp}
fi

cd $Target || exit

logfile="logs/recon.log"

log(){
        echo -e "$1"
        echo "$(date) : $1" >> $logfile
}

retry_command(){
        n=0
        until [ $n -ge 3 ]
        do
                "$@" && break
                n=$((n+1))
                sleep 2
        done
}

log "${blue}[+] Starting ReconForge On $Target${reset}"

cp subs/final.txt subs/old.txt 2>/dev/null

log "${blue}[+] Running Subdomain Enumeration${reset}"

retry_command subfinder -d $Target -silent >> subs/subdomains.txt &
retry_command assetfinder -subs-only $Target >> subs/subdomains.txt &
retry_command amass enum -passive -d $Target >> subs/subdomains.txt &

wait

python3 /home/omkar/project/bash/bugbounty/subwalker/tools/Sublist3r/sublist3r.py -d $Target -t 25 -o subs/sublist3r.txt

cat subs/sublist3r.txt >> subs/subdomains.txt

cat subs/subdomains.txt | sort | uniq > subs/final.txt

comm -13 subs/old.txt subs/final.txt > subs/new_subs.txt 2>/dev/null

log "${blue}[+] Resolving Domains${reset}"

cat subs/final.txt | dnsx -silent > probe/resolved.txt

log "${blue}[+] Finding Alive Hosts${reset}"

cat probe/resolved.txt | httpx -silent -threads $httpx_threads -rate-limit $httpx_rate -tech-detect -title -status-code -o probe/alive.txt

cat probe/alive.txt | cut -d ' ' -f1 | sed 's|http[s]*://||' | cut -d '/' -f1 > probe/hosts.txt

log "${blue}[+] Running Port Scan${reset}"

naabu -list probe/hosts.txt -silent -top-ports 100 -o ports/ports.txt

log "${blue}[+] Running Katana Crawling${reset}"

cat probe/alive.txt | cut -d ' ' -f1 | katana -silent -jc -kf all -o crawl/urls.txt

log "${blue}[+] Running JavaScript Secret Hunting${reset}"

cat crawl/urls.txt | grep "\.js$" > secrets/jsfiles.txt

cat secrets/jsfiles.txt | while read js
ndo
        if curl --output /dev/null --silent --head --fail "$js"
        then
                timeout 30 python3 /opt/SecretFinder/SecretFinder.py -i $js -o cli >> secrets/secrets.txt
        else
                echo "$js unreachable" >> logs/js_errors.txt
        fi
done

log "${blue}[+] Running API Discovery${reset}"

cat probe/alive.txt | cut -d ' ' -f1 | xargs -I{} -P $parallel_jobs sh -c 'kiterunner scan {} -w routes-large.kite -o api/$(echo {} | sed "s|https\?://||").txt'

log "${blue}[+] Running Content Discovery${reset}"

mkdir -p content/results

cat probe/alive.txt | grep "200" | grep -vE "\.(jpg|png|jpeg|svg|css|woff|gif)$" | cut -d ' ' -f1 | while read url
ndo
        domain=$(echo $url | sed 's|https\?://||')

        ffuf -u "$url/FUZZ" -w /usr/share/wordlists/dirb/common.txt -mc 200,204,301,302,307,401,403 -t $ffuf_threads -p $ffuf_delay -s -o content/results/$domain.json -of json
done

log "${blue}[+] Running Screenshots${reset}"

gowitness scan file -f probe/alive.txt --screenshot-path screenshots/

log "${blue}[+] Running Nuclei${reset}"

if [ "$Mode" == "quick" ]
then
        nuclei -l probe/alive.txt -severity critical,high -o nuclei/results.txt
else
        nuclei -l probe/alive.txt -severity low,medium,high,critical -o nuclei/results.txt
fi

log "${blue}[+] Parsing Nuclei Results${reset}"

grep -i "critical" nuclei/results.txt > reports/critical.txt
grep -i "high" nuclei/results.txt > reports/high.txt
grep -i "medium" nuclei/results.txt > reports/medium.txt
grep -i "low" nuclei/results.txt > reports/low.txt

critical=$(wc -l < reports/critical.txt)
high=$(wc -l < reports/high.txt)
medium=$(wc -l < reports/medium.txt)
low=$(wc -l < reports/low.txt)

subs=$(wc -l < subs/final.txt)
alive=$(wc -l < probe/alive.txt)
ports=$(wc -l < ports/ports.txt)
vulns=$(wc -l < nuclei/results.txt)
newsubs=$(wc -l < subs/new_subs.txt)

log "${blue}[+] Parsing FFUF Results${reset}"

find content/results -name "*.json" | while read file
do
        jq -r '.results[] | "\(.status) \(.url)"' $file >> reports/ffuf_summary.txt 2>/dev/null
done

log "${blue}[+] Generating Markdown Report${reset}"

echo "# ReconForge Report - $Target" > reports/report.md
echo "" >> reports/report.md

echo "## Scan Statistics" >> reports/report.md
echo "" >> reports/report.md
echo "- Total Subdomains : $subs" >> reports/report.md
echo "- New Subdomains : $newsubs" >> reports/report.md
echo "- Alive Hosts : $alive" >> reports/report.md
echo "- Open Ports : $ports" >> reports/report.md
echo "- Vulnerabilities : $vulns" >> reports/report.md

echo "" >> reports/report.md
echo "## Nuclei Severity Breakdown" >> reports/report.md
echo "" >> reports/report.md
echo "- Critical : $critical" >> reports/report.md
echo "- High : $high" >> reports/report.md
echo "- Medium : $medium" >> reports/report.md
echo "- Low : $low" >> reports/report.md

echo "" >> reports/report.md
echo "## Top Critical Findings" >> reports/report.md
echo "" >> reports/report.md
echo '```' >> reports/report.md
head -10 reports/critical.txt >> reports/report.md
echo '```' >> reports/report.md

echo "" >> reports/report.md
echo "## Top High Findings" >> reports/report.md
echo "" >> reports/report.md
echo '```' >> reports/report.md
head -10 reports/high.txt >> reports/report.md
echo '```' >> reports/report.md

echo "" >> reports/report.md
echo "## FFUF Interesting Endpoints" >> reports/report.md
echo "" >> reports/report.md
echo '```' >> reports/report.md
head -20 reports/ffuf_summary.txt >> reports/report.md
echo '```' >> reports/report.md

echo "" >> reports/report.md
echo "## Screenshots" >> reports/report.md
echo "" >> reports/report.md
echo "Saved inside screenshots/ directory" >> reports/report.md

log "${blue}[+] Cleaning Temporary Files${reset}"

rm -f subs/subdomains.txt
rm -f subs/sublist3r.txt
rm -f probe/hosts.txt

log "${green}[+] Recon Finished Successfully${reset}"

echo ""
echo -e "${yellow}[+] Scan Summary${reset}"
echo "Subdomains Found : $subs"
echo "New Subdomains   : $newsubs"
echo "Alive Hosts      : $alive"
echo "Open Ports       : $ports"
echo "Vulnerabilities  : $vulns"
echo ""
echo "Critical : $critical"
echo "High     : $high"
echo "Medium   : $medium"
echo "Low      : $low"
echo ""
echo -e "${green}[+] Report Saved : reports/report.md${reset}"
