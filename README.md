# PMABF — Ethical Use & Defensive Research README

> **Important:** This repository contains code that, as-written, automates password guessing against a phpMyAdmin login page. The document below is written *only* for ethical, legal, and defensive research use: testing in your own isolated lab systems or on systems for which you have explicit written authorization.

---

## Table of contents

* Legal & Ethical Notice
* Intended purpose
* Safe lab setup (recommended)
* What this repository contains (code overview)
* Installation (dependencies)
* How to *review* and *test* this code safely (defensive/research guidelines)
* Suggested improvements & hardening notes (defensive focus)
* Logging & result handling (privacy-conscious)
* Contributing
* License

---

## Legal & Ethical Notice

By interacting with this repository or any code derived from it you confirm you will only use it:

* Within an isolated test environment (e.g., local VMs, disposable containers), **or**
* Against systems for which you have **explicit, written authorization** to perform security testing.

Unauthorized password guessing or brute-force attacks are illegal and unethical. If you are uncertain about permissions, do not run this code.

If your goal is to improve security, focus on **defense**, vulnerability remediation, and responsible disclosure.

---

## Intended purpose

This repository should be used only for:

* Educational study of how automated login attempts are detected and mitigated,
* Defensive research: designing detection rules, rate-limiting and lockout policies,
* Testing incident response and monitoring in an authorized lab.

It is **not** intended to be used for attacking live systems or accounts without permission.

---

## Safe lab setup (recommended)

Before running any experiments, create an isolated environment:

1. Create a virtual network containing a small number of VMs or containers (e.g., using VirtualBox, Vagrant, Docker).
2. Install a web stack and phpMyAdmin on one VM. Use a throwaway database and accounts.
3. Ensure the environment is firewalled from the public internet.
4. Snapshot/backup your VMs so you can revert changes.
5. Keep logs and capture traffic in the lab (e.g., tcpdump or Wireshark) to study behavior.

This ensures experiments do not affect others or violate policy.

---

## What this repository contains (code overview)

* `pma_bf.rb` (example): A multi-threaded Ruby script that performs automated HTTP requests and attempts to authenticate to a phpMyAdmin login page.
* `users.txt` / `pass.txt`: Wordlists used by the script.
* `resume.txt`, `results.csv`: Files used to track progress and logging output.

**Note:** The code as-provided demonstrates concepts such as:

* HTTP request/response handling
* Form field extraction from HTML
* Threading and concurrency control
* Basic progress persistence and logging

Do not use these artifacts against systems without authorization.

---

## Installation (dependencies)

Only install and run these dependencies in an isolated test environment.

* Ruby (2.5+ recommended)
* Standard Ruby libraries used: `net/http`, `uri`, `thread`, `time`

Example (on a lab VM):

```bash
# install ruby (example for Debian/Ubuntu)
sudo apt update && sudo apt install -y ruby
```

---

## How to *review* and *test* this code safely (defensive/research guidelines)

If your goal is defensive testing or learning, follow these rules:

1. **Code review only** — read the script and understand how it constructs HTTP requests and parses responses.
2. **Static analysis** — search for hard-coded secrets or surprising network behavior.
3. **Behavioral testing (lab only)** — run the code in the isolated lab. Monitor the server and network while the script runs.
4. **Logging & monitoring** — instrument the target server (in the lab) with extra logging, enable audit trails, and watch for patterns the script generates (failed-attempt spikes, unusual IPs).
5. **Detection rules** — use the observed patterns to craft IDS/IPS rules and rate-limiting policies.

**Do not** publish logs or results from real accounts or real systems.

---

## Suggested improvements & hardening notes (defensive focus)

Below are defensive recommendations you can apply to phpMyAdmin or any web application:

* Enforce IP-based rate-limiting and account lockout policies after repeated failed attempts.
* Use multi-factor authentication (MFA) for administrative accounts.
* Move the admin interface behind VPN or restrict access by IP where possible.
* Rename or protect common admin paths (security through obscurity alone is insufficient).
* Use strong password policies and password managers.
* Deploy a Web Application Firewall (WAF) to block automated attack patterns.
* Enable HTTPS and ensure certificates are up-to-date.
* Use tools like `fail2ban` to block repeated offenders at the host level.
* Log failed authentication attempts with timestamps, source IP, and user-agent for analysis.

These measures reduce the effectiveness of automated guessing attempts.

---

## Logging & result handling (privacy-conscious)

* When recording test results, avoid storing or sharing cleartext passwords from any real accounts.
* Keep logs within your lab and ensure they are securely stored and later deleted if they contain sensitive data.
* Anonymize or redact any personally identifiable information before sharing research outputs.

---

## Contributing

If you want to contribute defensive improvements to this repository, suggested contribution areas:

* Add a `lab/` folder containing reproducible instructions for setting up the isolated test environment (Vagrantfile or Docker Compose) that does **not** expose the service to the internet.
* Add scripts that simulate attacker behavior at varying rates for detection testing — but ensure they are clearly labeled and restricted to lab use only.
* Add defensive configuration examples for phpMyAdmin and web servers demonstrating recommended hardening.

Pull requests should include a clear statement that the code is for **authorized, lab-only use**.

---

## License

This repository is provided for educational and defensive research purposes only. Use at your own risk. The author is not responsible for misuse.

---
