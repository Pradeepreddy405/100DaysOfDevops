# Apache Service Troubleshooting & Port Configuration – 8082

## 📌 Task

The production support team reported that the **Apache HTTP server (`httpd`) service was unavailable on one of the application servers** in the **Stratos Data Center (DC)**.

### Requirements

1. Identify the faulty application server.
2. Fix the Apache service.
3. Ensure Apache is running on **all application servers**.
4. Configure Apache to listen on **port `8082`** on all application servers.
5. Apache does not need to serve application code. Only service availability is required.
6. Ensure Apache starts automatically after a server reboot.

---

# 🏗️ Infrastructure

| Server | Hostname | Purpose |
|---|---|---|
| Application Server 1 | `stapp01` | Nautilus Application 1 |
| Application Server 2 | `stapp02` | Nautilus Application 2 |
| Application Server 3 | `stapp03` | Nautilus Application 3 |
| Load Balancer | `stlb01` | Distributes HTTP traffic |
| Jump Host | `jump-host` | Access point to Stratos DC |

---

# 🔎 Step 1: Check Apache Service Status

SSH into each application server and check the Apache service.

```bash
sudo systemctl status httpd
```

A healthy server should show:

```text
Active: active (running)
```

If you see:

```text
Active: failed
```

or:

```text
Active: inactive (dead)
```

the server requires troubleshooting.

### Quick status check

Instead of the full status output, you can use:

```bash
sudo systemctl is-active httpd
```

Expected:

```text
active
```

---

# 🔎 Step 2: Check Whether Apache Is Listening on Port 8082

Run:

```bash
sudo ss -lntp | grep :8082
```

Expected output will look similar to:

```text
LISTEN 0 511 0.0.0.0:8082 0.0.0.0:* users:(("httpd",pid=1234,fd=4))
```

This confirms that a process is listening on port `8082`.

The important part is:

```text
:8082
```

and ideally:

```text
httpd
```

---

# 🔎 Step 3: Identify the Faulty Application Server

Check all three application servers.

## Application Server 1

Connect:

```bash
ssh tony@stapp01
```

Check Apache:

```bash
sudo systemctl status httpd
```

Check port:

```bash
sudo ss -lntp | grep :8082
```

Exit:

```bash
exit
```

---

## Application Server 2

Connect:

```bash
ssh steve@stapp02
```

Check Apache:

```bash
sudo systemctl status httpd
```

Check port:

```bash
sudo ss -lntp | grep :8082
```

Exit:

```bash
exit
```

---

## Application Server 3

Connect:

```bash
ssh banner@stapp03
```

Check Apache:

```bash
sudo systemctl status httpd
```

Check port:

```bash
sudo ss -lntp | grep :8082
```

---

# 🛠️ Step 4: Troubleshoot the Faulty Server

If Apache is not running, do not immediately restart it.

First determine why it failed.

### Check Apache logs

```bash
sudo journalctl -u httpd --no-pager -n 30
```

This displays the latest Apache service logs.

Look for errors such as:

```text
Address already in use
Syntax error
Permission denied
Could not bind to address
```

---

# 🔎 Step 5: Check Apache Configuration

Check the configured `Listen` directives:

```bash
sudo grep -R "^[[:space:]]*Listen" /etc/httpd/conf /etc/httpd/conf.d
```

The required configuration is:

```apache
Listen 8082
```

If Apache is configured to listen on another port, edit the appropriate configuration file.

For example:

```bash
sudo vi /etc/httpd/conf/httpd.conf
```

Change:

```apache
Listen 80
```

to:

```apache
Listen 8082
```

> **Important:** Before changing a configuration file, check whether another Apache configuration file also contains a `Listen` directive. Apache should not have conflicting `Listen` directives for the same address/port.

---

# 🧪 Step 6: Validate Apache Configuration

**Always validate Apache configuration before restarting the service.**

Run:

```bash
sudo apachectl configtest
```

Expected:

```text
Syntax OK
```

If you receive an error, fix the configuration before attempting to start or restart Apache.

---

# ▶️ Step 7: Start Apache

If Apache is stopped:

```bash
sudo systemctl start httpd
```

Check the service:

```bash
sudo systemctl status httpd
```

Expected:

```text
Active: active (running)
```

---

# 🔄 Step 8: Enable Apache at Boot

To make Apache start automatically after a reboot:

```bash
sudo systemctl enable httpd
```

Verify:

```bash
sudo systemctl is-enabled httpd
```

Expected:

```text
enabled
```

### Important Difference

```bash
systemctl start httpd
```

Starts Apache **right now**.

```bash
systemctl enable httpd
```

Configures Apache to **start automatically during boot**.

You normally need both:

```bash
sudo systemctl start httpd
sudo systemctl enable httpd
```

---

# 🔍 Step 9: Verify Port 8082

Check the listening port:

```bash
sudo ss -lntp | grep :8082
```

Expected:

```text
LISTEN ... :8082 ... httpd
```

You can also test Apache locally:

```bash
curl http://localhost:8082
```

A response such as:

```text
403 Forbidden
```

or:

```text
404 Not Found
```

can still indicate that Apache itself is running.

The requirement does **not** require Apache to serve application code.

---

# 🔄 Step 10: Verify All Application Servers

The final state should be:

```text
stapp01 → httpd active → port 8082
stapp02 → httpd active → port 8082
stapp03 → httpd active → port 8082
```

Run the following on **each application server**.

### Check service status

```bash
sudo systemctl is-active httpd
```

Expected:

```text
active
```

### Check boot configuration

```bash
sudo systemctl is-enabled httpd
```

Expected:

```text
enabled
```

### Check port

```bash
sudo ss -lntp | grep :8082
```

Expected:

```text
LISTEN ... :8082 ... httpd
```

---

# ⚠️ Troubleshooting: Port Already in Use

If Apache fails to start and you see:

```text
(98) Address already in use
```

do **not** immediately kill a process.

Another process may already be using port `8082`.

First identify the process:

```bash
sudo ss -lntp | grep :8082
```

Or:

```bash
sudo lsof -i :8082
```

Example:

```text
COMMAND  PID  USER  FD  TYPE DEVICE SIZE/OFF NODE NAME
java     1234 root  50u IPv4  ...      TCP *:8082 (LISTEN)
```

This tells you that another process is already listening on port `8082`.

### Next Steps

1. Identify the process.
2. Determine whether it should be using port `8082`.
3. Check its configuration.
4. Decide whether the process should be stopped or moved to another port.
5. Start Apache again.
6. Verify that `httpd` owns port `8082`.

Do not blindly terminate processes in a production environment.

---

# 🧰 Useful Troubleshooting Commands

### Check Apache service

```bash
sudo systemctl status httpd
```

### Check whether Apache is running

```bash
sudo systemctl is-active httpd
```

### Check whether Apache starts at boot

```bash
sudo systemctl is-enabled httpd
```

### Start Apache

```bash
sudo systemctl start httpd
```

### Stop Apache

```bash
sudo systemctl stop httpd
```

### Restart Apache

```bash
sudo systemctl restart httpd
```

### Enable Apache at boot

```bash
sudo systemctl enable httpd
```

### Validate configuration

```bash
sudo apachectl configtest
```

### Check listening ports

```bash
sudo ss -lntp
```

### Check port 8082

```bash
sudo ss -lntp | grep :8082
```

### Identify the process using port 8082

```bash
sudo lsof -i :8082
```

### Check Apache logs

```bash
sudo journalctl -u httpd --no-pager -n 30
```

### Test Apache locally

```bash
curl http://localhost:8082
```

---

# 🧠 Complete Troubleshooting Workflow

A good production troubleshooting sequence is:

```text
             Apache unavailable
                    |
                    ↓
          Check systemctl status
                    |
                    ↓
          Is Apache running?
             /          \
           YES           NO
            |             |
            ↓             ↓
      Check port      Check logs
            |             |
            ↓             ↓
      Is 8082 open?   Find root cause
            |             |
            ↓             ↓
       Check config ← Fix configuration
            |
            ↓
    apachectl configtest
            |
            ↓
        Syntax OK?
            |
            ↓
      Start/Restart Apache
            |
            ↓
       Enable at boot
            |
            ↓
      Verify port 8082
            |
            ↓
      Test with curl
            |
            ↓
     Verify all servers
```

---

# ✅ Final Verification Checklist

Perform these checks on **`stapp01`**, **`stapp02`**, and **`stapp03`**.

- [ ] Apache service is running.
- [ ] Apache configuration passes `apachectl configtest`.
- [ ] Apache is listening on port `8082`.
- [ ] Apache is enabled to start after reboot.
- [ ] Port `8082` is not occupied by an unexpected process.
- [ ] `curl http://localhost:8082` receives an HTTP response.
- [ ] All three application servers have the same required Apache configuration.

Expected final state:

```text
┌──────────┬─────────────────┬────────────┐
│ Server   │ Apache Status   │ Port       │
├──────────┼─────────────────┼────────────┤
│ stapp01  │ active          │ 8082       │
│ stapp02  │ active          │ 8082       │
│ stapp03  │ active          │ 8082       │
└──────────┴─────────────────┴────────────┘
```

---

# 🎯 Interview Explanation

> **"I first checked the Apache service status and listening ports on all three application servers to identify the faulty host. On the faulty server, I checked the Apache logs and configuration to determine the root cause instead of blindly restarting the service. I configured Apache to listen on port 8082, validated the configuration using `apachectl configtest`, started the service, and enabled it to start automatically after reboot. Finally, I verified that Apache was active and listening on port 8082 on all application servers."**

---

# 📚 Key Concepts Learned

| Command | Purpose |
|---|---|
| `systemctl status httpd` | Check detailed Apache service status |
| `systemctl start httpd` | Start Apache |
| `systemctl stop httpd` | Stop Apache |
| `systemctl restart httpd` | Restart Apache |
| `systemctl enable httpd` | Enable Apache at boot |
| `systemctl is-active httpd` | Quickly check whether Apache is running |
| `systemctl is-enabled httpd` | Check whether Apache starts at boot |
| `ss -lntp` | Display listening TCP ports and processes |
| `lsof -i :8082` | Identify the process using port 8082 |
| `apachectl configtest` | Validate Apache configuration |
| `journalctl -u httpd` | View Apache systemd logs |
| `curl localhost:8082` | Test Apache locally |

---

# 🚀 Production Support Mindset

The most important lesson from this task is:

> **Don't blindly restart a failed service. First identify the root cause.**

A strong troubleshooting approach is:

```text
Check
  ↓
Identify
  ↓
Investigate
  ↓
Fix
  ↓
Validate
  ↓
Restart/Start
  ↓
Verify
  ↓
Monitor
```

This approach is useful not only for Apache but also for services such as:

```text
Nginx
SSH
Docker
PostgreSQL
MySQL
Jenkins
Kubernetes components
Application services
```

The goal of production support is not simply to make a service **"green"**. The goal is to understand **why it failed, fix the root cause, and verify that the service remains healthy.**