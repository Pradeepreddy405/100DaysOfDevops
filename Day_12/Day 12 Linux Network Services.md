# Apache HTTPD Troubleshooting – Port Conflict and Firewall Configuration

## Lab Overview

This lab demonstrates how to troubleshoot an Apache HTTPD service that failed to start because its configured port was already being used by another service.

### Environment

- **Jump Host:** `jump-host`
- **Application Server:** `stapp01`
- **Apache Service:** `httpd`
- **Apache Port:** `3001`
- **Conflicting Service:** `sendmail`
- **Firewall:** `iptables`

---

# 1. Problem Statement : Linux Network services

Apache HTTPD was expected to run on port `3001`, but the Apache service was failing to start.

The objective was to:

1. Check the Apache service status.
2. Find the actual reason for the failure.
3. Identify what process was already using port `3001`.
4. Stop the conflicting service.
5. Start Apache successfully.
6. Verify Apache's listening port.
7. Check the firewall.
8. Allow TCP port `3001`.
9. Test Apache using `curl`.

---

# 2. Connect to the Application Server

From the Jump Host:

```bash
ssh tony@stapp01
```

Verify the logged-in user:

```bash
whoami
```

Expected:

```text
tony
```

Verify the hostname:

```bash
hostname
```

Expected:

```text
stapp01
```

This confirms that we are working on the correct application server.

---

# 3. Check Apache Service Status

Run:

```bash
sudo systemctl status httpd
```

The service showed:

```text
Active: failed
```

and:

```text
status=1/FAILURE
```

### What does this tell us?

Apache is not running.

However, `systemctl status` only tells us that Apache failed. It does not necessarily tell us the root cause.

Therefore, the next step is to inspect the Apache logs.

---

# 4. Check Apache Logs

Run:

```bash
sudo journalctl -u httpd --no-pager -n 50
```

Important error:

```text
(98)Address already in use
AH00072: make_sock: could not bind to address [::]:3001
```

and:

```text
(98)Address already in use
AH00072: make_sock: could not bind to address 0.0.0.0:3001
```

### Root Cause Identified

Apache is configured to use port `3001`, but another process is already using that port.

Therefore:

```text
Apache
   |
   | wants port 3001
   ↓
Port 3001
   |
   | already occupied
   ↓
Apache cannot start
```

Now we need to identify which process owns port `3001`.

---

# 5. Find the Process Using Port 3001

Run:

```bash
sudo ss -lntp | grep :3001
```

Output showed:

```text
LISTEN 0 10 127.0.0.1:3001 0.0.0.0:* users:(("sendmail",pid=37751,fd=4))
```

### Interpretation

The important information is:

```text
Port: 3001
Process: sendmail
PID: 37751
```

Therefore:

> `sendmail` is already listening on port `3001`.

This creates a port conflict.

```text
             Port 3001
                 |
        +--------+--------+
        |                 |
     Apache            sendmail
     wants it          owns it
        |                 |
        +------ CONFLICT -+
```

Apache cannot bind to a port that is already occupied.

---

# 6. Stop the Conflicting Service

Since `sendmail` is using the port, stop it:

```bash
sudo systemctl stop sendmail
```

Check its status:

```bash
sudo systemctl status sendmail
```

Expected:

```text
Active: inactive (dead)
```

This confirms that the sendmail service has been stopped.

---

# 7. Verify That Port 3001 Is Free

Do not assume that stopping the service freed the port.

Verify it:

```bash
sudo ss -lntp | grep :3001
```

There was no output.

That means:

```text
Port 3001
    ↓
No process listening
    ↓
Port is free
```

This is an important troubleshooting habit:

> After changing something, verify the actual system state instead of assuming the change worked.

---

# 8. Start Apache

Start Apache:

```bash
sudo systemctl start httpd
```

Then check the service:

```bash
sudo systemctl status httpd
```

Expected:

```text
Active: active (running)
```

The logs also showed:

```text
Server configured, listening on port 3001
```

and:

```text
Started The Apache HTTP Server.
```

### Result

The original Apache startup problem has now been resolved.

```text
sendmail stopped
      ↓
port 3001 became free
      ↓
Apache started
      ↓
Apache listening on 3001
```

---

# 9. Verify Apache's Port Configuration

Check Apache's `Listen` directive:

```bash
sudo grep -Rni "Listen" /etc/httpd/
```

The important configuration line was:

```text
/etc/httpd/conf/httpd.conf:47:Listen 3001
```

Therefore Apache is configured to listen on:

```text
3001
```

### Better command

Because recursive `grep` also searches binary Apache modules, a cleaner command is:

```bash
sudo grep -Rni "^[[:space:]]*Listen" /etc/httpd/conf /etc/httpd/conf.d/
```

Expected:

```text
Listen 3001
```

### What does `Listen 3001` mean?

It tells Apache:

> Listen for incoming network connections on TCP port `3001`.

---

# 10. Check the Firewall

Now that Apache is running, we need to verify whether the server firewall allows incoming traffic to port `3001`.

Run:

```bash
sudo iptables -L -n -v
```

### Meaning of the command

| Option | Meaning |
|---|---|
| `-L` | List firewall rules |
| `-n` | Display numeric IP addresses and ports |
| `-v` | Verbose output |
| `sudo` | Run with root privileges |

We then specifically checked the INPUT chain for port `3001`:

```bash
sudo iptables -L INPUT -n --line-numbers | grep 3001
```

Initially, there was no rule allowing TCP port `3001`.

---

# 11. Allow TCP Port 3001

Add an INPUT rule:

```bash
sudo iptables -I INPUT -p tcp --dport 3001 -j ACCEPT
```

### Command breakdown

```text
-I INPUT
```

Insert the rule into the INPUT chain.

```text
-p tcp
```

The rule applies to TCP traffic.

```text
--dport 3001
```

The destination port is `3001`.

```text
-j ACCEPT
```

Allow the traffic.

Therefore the complete rule means:

> Allow incoming TCP traffic destined for port `3001`.

---

# 12. Verify the Firewall Rule

Run:

```bash
sudo iptables -L INPUT -n --line-numbers | grep 3001
```

Expected:

```text
1  ACCEPT  tcp  --  0.0.0.0/0  0.0.0.0/0  tcp dpt:3001
```

This confirms that the firewall has an ACCEPT rule for port `3001`.

---

# 13. Test Apache

Run:

```bash
curl -I http://stapp01:3001
```

The response was:

```text
HTTP/1.1 403 Forbidden
Server: Apache/2.4.62 (CentOS Stream)
```

## Is `403 Forbidden` a failure of the port?

No.

This is an important troubleshooting distinction.

A response such as:

```text
HTTP/1.1 403 Forbidden
```

means the request successfully reached Apache and Apache responded.

The communication path is therefore working:

```text
curl
  |
  | TCP connection
  ↓
stapp01:3001
  |
  ↓
Apache
  |
  ↓
HTTP 403 response
```

The `403` is now an **Apache/application-level access problem**, not a port-listening problem.

Possible next areas to investigate for a 403 include:

- Directory permissions
- Apache `<Directory>` configuration
- Document root
- SELinux
- Apache access restrictions
- `.htaccess`
- File permissions/ownership

But those are separate from the original port conflict.

---

# 14. Final Troubleshooting Flow

The complete troubleshooting process was:

```text
Apache not working
        |
        ↓
systemctl status httpd
        |
        ↓
Apache FAILED
        |
        ↓
journalctl -u httpd
        |
        ↓
"Address already in use"
        |
        ↓
ss -lntp | grep :3001
        |
        ↓
sendmail owns port 3001
        |
        ↓
systemctl stop sendmail
        |
        ↓
ss -lntp | grep :3001
        |
        ↓
Port 3001 is free
        |
        ↓
systemctl start httpd
        |
        ↓
Apache ACTIVE
        |
        ↓
Check Listen configuration
        |
        ↓
Listen 3001
        |
        ↓
Check iptables
        |
        ↓
No rule for 3001
        |
        ↓
Allow TCP 3001
        |
        ↓
Verify firewall rule
        |
        ↓
curl http://stapp01:3001
        |
        ↓
HTTP 403 Forbidden
        |
        ↓
Apache is reachable
```

---

# 15. Commands Used

For quick reference:

```bash
# Connect to server
ssh tony@stapp01

# Verify user and hostname
whoami
hostname

# Check Apache
sudo systemctl status httpd

# Check Apache logs
sudo journalctl -u httpd --no-pager -n 50

# Find process using port 3001
sudo ss -lntp | grep :3001

# Stop conflicting service
sudo systemctl stop sendmail

# Verify sendmail
sudo systemctl status sendmail

# Verify port is free
sudo ss -lntp | grep :3001

# Start Apache
sudo systemctl start httpd

# Verify Apache
sudo systemctl status httpd

# Check Apache Listen configuration
sudo grep -Rni "^[[:space:]]*Listen" /etc/httpd/conf /etc/httpd/conf.d/

# Check iptables
sudo iptables -L -n -v

# Check port 3001 firewall rule
sudo iptables -L INPUT -n --line-numbers | grep 3001

# Allow TCP port 3001
sudo iptables -I INPUT -p tcp --dport 3001 -j ACCEPT

# Verify firewall rule
sudo iptables -L INPUT -n --line-numbers | grep 3001

# Test Apache
curl -I http://stapp01:3001
```

---

# 16. Key DevOps Lessons

### 1. `systemctl status` tells you WHAT happened

```bash
sudo systemctl status httpd
```

Example:

```text
Active: failed
```

Apache failed, but we still need the reason.

---

### 2. `journalctl` tells you WHY it happened

```bash
sudo journalctl -u httpd --no-pager -n 50
```

In this lab:

```text
Address already in use
```

gave us the actual root cause.

---

### 3. `ss` tells you WHO owns the port

```bash
sudo ss -lntp | grep :3001
```

In this lab:

```text
sendmail → 3001
```

This identified the conflict.

---

### 4. `Listen` tells you WHAT port Apache wants

```text
Listen 3001
```

Apache was configured for port `3001`.

---

### 5. `iptables` controls network access

```bash
sudo iptables -L -n -v
```

and:

```bash
sudo iptables -I INPUT -p tcp --dport 3001 -j ACCEPT
```

allow incoming traffic to port `3001`.

---

### 6. `curl` tests the final result

```bash
curl -I http://stapp01:3001
```

A response such as:

```text
HTTP/1.1 403 Forbidden
```

still proves that the request reached Apache.

The problem has moved from:

```text
Service / Port / Network
```

to:

```text
Apache access / permissions / SELinux / configuration
```

---

# 17. Troubleshooting Principle

The biggest lesson from this lab is:

> **Do not guess the problem. Follow the evidence.**

Use this general DevOps pattern:

```text
CHECK
  ↓
OBSERVE ERROR
  ↓
FIND ROOT CAUSE
  ↓
FIX ROOT CAUSE
  ↓
VERIFY FIX
  ↓
TEST FROM CLIENT
```

For this particular incident:

```text
Apache failed
    ↓
Logs
    ↓
Port 3001 already in use
    ↓
ss
    ↓
sendmail owns 3001
    ↓
Stop sendmail
    ↓
Start Apache
    ↓
Check firewall
    ↓
Allow 3001
    ↓
curl
    ↓
Apache responds with 403
```

This is the troubleshooting methodology you should carry into real DevOps/SRE work.