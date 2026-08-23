# Apache Static Websites on App Server 2

## 📌 Lab Overview

**Project:** Nautilus / xFusionCorp Industries  
**Server:** Application Server 2 (`stapp02`)  
**Web Server:** Apache HTTP Server (`httpd`)  
**Apache Port:** `8083`

### Objective

Configure Apache on **Application Server 2** to host two static websites:

- `official`
- `cluster`

The websites should be accessible through:

```text
http://localhost:8083/official/
http://localhost:8083/cluster/
```

---

## 🏗️ Infrastructure

| Server | Hostname | User | Purpose |
|---|---|---|---|
| Application Server 2 | `stapp02` | `steve` | Hosts Apache websites |
| Jump Host | `jump-host` | `thor` | Contains website backups |

### Website Backups

```text
/home/thor/official
/home/thor/cluster
```

---

# 🔧 Implementation

## 1. Connect to App Server 2

From the Jump Host:

```bash
ssh steve@stapp02
```

---

## 2. Install Apache

Install the `httpd` package and dependencies:

```bash
sudo dnf install -y httpd
```

Verify installation:

```bash
httpd -v
```

---

## 3. Change Apache Port

Edit the Apache configuration:

```bash
sudo vi /etc/httpd/conf/httpd.conf
```

Change:

```apache
Listen 80
```

to:

```apache
Listen 8083
```

Verify:

```bash
grep -n "^Listen" /etc/httpd/conf/httpd.conf
```

Expected:

```text
Listen 8083
```

---

# 📦 4. Copy Website Backups

The website backups are located on the Jump Host under `/home/thor`.

From the Jump Host, copy them to `stapp02`:

### Copy Official Website

```bash
scp -r /home/thor/official steve@stapp02:/tmp/
```

### Copy Cluster Website

```bash
scp -r /home/thor/cluster steve@stapp02:/tmp/
```

Enter the `steve` user's password when prompted.

---

# 📁 5. Deploy Websites

Login to `stapp02`:

```bash
ssh steve@stapp02
```

Copy the websites into Apache's document root:

```bash
sudo cp -r /tmp/official /var/www/html/
sudo cp -r /tmp/cluster /var/www/html/
```

Verify:

```bash
ls -l /var/www/html/
```

Expected structure:

```text
/var/www/html/
├── official/
│   └── ...
└── cluster/
    └── ...
```

---

# 🔐 6. Set Permissions

Set Apache as the owner:

```bash
sudo chown -R apache:apache /var/www/html/official
sudo chown -R apache:apache /var/www/html/cluster
```

Set appropriate permissions:

```bash
sudo chmod -R 755 /var/www/html/official
sudo chmod -R 755 /var/www/html/cluster
```

---

# 🚀 7. Start Apache

Enable Apache at boot and start it:

```bash
sudo systemctl enable --now httpd
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

# 🔍 8. Verify Apache Port

Check whether Apache is listening on port `8083`:

```bash
sudo ss -lntp | grep 8083
```

Expected:

```text
LISTEN ... 0.0.0.0:8083 ... httpd
```

---

# 🧪 9. Test Official Website

Run:

```bash
curl http://localhost:8083/official/
```

The response should contain the HTML/content of the **official** website.

---

# 🧪 10. Test Cluster Website

Run:

```bash
curl http://localhost:8083/cluster/
```

The response should contain the HTML/content of the **cluster** website.

---

# 🏗️ Architecture

```text
                    Jump Host
                  ┌─────────────┐
                  │ thor        │
                  │             │
                  │ /home/thor/ │
                  │  official/  │
                  │  cluster/   │
                  └──────┬──────┘
                         │
                    SCP Transfer
                         │
                         ▼
                ┌─────────────────┐
                │    stapp02      │
                │    steve        │
                │                 │
                │ Apache :8083    │
                └────────┬────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
              ▼                     ▼
       /official/              /cluster/
              │                     │
              ▼                     ▼
    /var/www/html/official  /var/www/html/cluster
              │                     │
              ▼                     ▼
       Official Website       Cluster Website
```

---

# 📋 Final Verification

Run all of the following on `stapp02`:

```bash
httpd -v
```

```bash
sudo systemctl status httpd
```

```bash
sudo ss -lntp | grep 8083
```

```bash
ls -la /var/www/html/official/
```

```bash
ls -la /var/www/html/cluster/
```

```bash
curl http://localhost:8083/official/
```

```bash
curl http://localhost:8083/cluster/
```

---

# ✅ Expected Result

| Requirement | Status |
|---|---|
| Install `httpd` | ✅ |
| Apache configured on `8083` | ✅ |
| Official website deployed | ✅ |
| Cluster website deployed | ✅ |
| `/official/` accessible | ✅ |
| `/cluster/` accessible | ✅ |
| Apache enabled at boot | ✅ |
| Websites verified with `curl` | ✅ |

---

## 🧠 Key DevOps Concepts Learned

- Apache HTTP Server installation
- Apache port configuration
- Linux service management with `systemctl`
- File transfer using `scp`
- Apache document root
- Linux ownership and permissions
- Static website deployment
- Port verification using `ss`
- Application testing using `curl`
- Troubleshooting web-server connectivity

---

## 🔑 Important Commands

```bash
sudo dnf install -y httpd

sudo vi /etc/httpd/conf/httpd.conf

sudo systemctl enable --now httpd

sudo ss -lntp | grep 8083

scp -r /home/thor/official steve@stapp02:/tmp/

scp -r /home/thor/cluster steve@stapp02:/tmp/

sudo cp -r /tmp/official /var/www/html/

sudo cp -r /tmp/cluster /var/www/html/

curl http://localhost:8083/official/

curl http://localhost:8083/cluster/
```

---

## 🎯 Real-World DevOps Mapping

This lab simulates a common production workflow:

```text
Developer / Build Server
          │
          ▼
     Website Build
          │
          ▼
    Artifact / Backup
          │
          ▼
      File Transfer
          │
          ▼
     Application Server
          │
          ▼
       Apache/Nginx
          │
          ▼
        Clients
```

The important skills demonstrated here are **Linux administration, Apache configuration, secure file transfer, permissions, service management, and deployment verification**.