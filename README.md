# ReconForge 🚀

Automated reconnaissance framework for web application security testing and bug bounty automation.

---

# Features 🔥

- Passive + active subdomain enumeration
- Alive host detection
- Port scanning
- Content discovery
- JavaScript secret hunting
- API endpoint discovery
- Vulnerability scanning
- Screenshot automation
- Markdown report generation
- Severity-based vulnerability parsing
- Parallel execution
- Retry logic
- Rate limiting
- Diff-based recon tracking

---

# Tools Used 🛠️

| Tool | Purpose |
|---|---|
| Subfinder | Passive subdomain enumeration |
| Assetfinder | Discover subdomains from public sources |
| Amass | Advanced attack surface mapping |
| Sublist3r | Additional subdomain enumeration |
| DNSX | DNS resolution and validation |
| HTTPX | Alive host detection and technology fingerprinting |
| Naabu | Fast port scanning |
| Katana | Web crawling and endpoint discovery |
| FFUF | Content and directory fuzzing |
| SecretFinder | JavaScript secret extraction |
| Kiterunner | API endpoint discovery |
| Nuclei | Vulnerability scanning |
| Gowitness | Screenshot automation |
| JQ | JSON parsing |
| Curl | HTTP request handling |

---

# Installation ⚙️

## Clone Repository

```bash
git clone https://github.com/OMKARTANDALE/ReconForge.git
cd ReconForge
```

---

# Install Dependencies

## Install Golang

```bash
sudo apt install golang -y
```

---

## Install Recon Tools

```bash
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

go install github.com/projectdiscovery/httpx/cmd/httpx@latest

go install github.com/projectdiscovery/dnsx/cmd/dnsx@latest

go install github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

go install github.com/projectdiscovery/katana/cmd/katana@latest

go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

go install github.com/tomnomnom/assetfinder@latest

go install github.com/ffuf/ffuf/v2@latest

go install github.com/sensepost/gowitness@latest

go install github.com/assetnote/kiterunner@latest
```

---

## Install Python Tools

### Sublist3r

```bash
git clone https://github.com/aboul3la/Sublist3r.git
```

```bash
pip install -r requirements.txt
```

---

### SecretFinder

```bash
git clone https://github.com/m4ll0k/SecretFinder.git
```

```bash
pip install -r requirements.txt
```

---

## Install Additional Packages

```bash
sudo apt install amass jq curl dirb -y
```

---

# Add Go Binary Path

```bash
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc

source ~/.bashrc
```

---

# Usage 🚀

## Quick Scan

```bash
chmod +x reconforge.sh

./reconforge.sh example.com quick
```

---

## Deep Scan

```bash
./reconforge.sh example.com deep
```

---

# Scan Modes ⚡

| Mode | Description |
|---|---|
| quick | Critical + high severity scans |
| deep | Full reconnaissance and vulnerability assessment |

---

# Project Structure 📂

```text
ReconForge/
│
├── reconforge.sh
├── README.md
├── LICENSE
├── .gitignore
│
├── config/
├── modules/
├── parsers/
├── reports/
├── screenshots/
├── logs/
├── output/
├── docs/
└── wordlists/
```

---

# Output Structure 📄

| Folder | Description |
|---|---|
| subs/ | Subdomain results |
| probe/ | Alive hosts and probing |
| ports/ | Port scan results |
| content/ | FFUF content discovery |
| crawl/ | Crawled URLs |
| nuclei/ | Vulnerability scan results |
| secrets/ | JavaScript secrets |
| api/ | API discovery results |
| screenshots/ | Website screenshots |
| reports/ | Markdown reports |
| logs/ | Scan logs |

---

# Sample Workflow 🧠

```text
Subdomain Enumeration
        ↓
DNS Resolution
        ↓
Alive Host Detection
        ↓
Port Scanning
        ↓
Web Crawling
        ↓
Content Discovery
        ↓
Secret Hunting
        ↓
API Discovery
        ↓
Vulnerability Scanning
        ↓
Markdown Report Generation
```

---

# Example Report 📊

- Total Subdomains Found
- Alive Hosts
- Open Ports
- Vulnerability Severity Breakdown
- Critical Findings
- High Findings
- Interesting FFUF Endpoints
- Screenshot References

---

# Disclaimer ⚠️

This project is intended for:
- authorized security testing
- bug bounty programs
- educational purposes
- lab environments

Do NOT use against unauthorized targets.

---

# Author 👨‍💻

OMKARTANDALE

GitHub : https://github.com/OMKARTANDALE
