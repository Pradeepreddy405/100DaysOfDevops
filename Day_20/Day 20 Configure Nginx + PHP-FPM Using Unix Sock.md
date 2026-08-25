# Configure Nginx + PHP-FPM Using Unix Socket

## 📌 Project Overview

This lab demonstrates how to deploy a PHP-based application using **Nginx + PHP-FPM** on the Nautilus infrastructure.

The application is hosted on **App Server 2 (`stapp02`)** in the Stratos Datacenter.

The main objective is to configure:

- Nginx on port `8093`
- Document root `/var/www/html`
- PHP-FPM version `8.2`
- PHP-FPM Unix socket `/var/run/php-fpm/default.sock`
- Nginx to forward PHP requests to PHP-FPM
- Verify the application from the Jump Host

The Nginx → PHP-FPM → Unix socket configuration is the key concept of this lab.

---

## 🏗️ Architecture

```text
                    HTTP Request
                         |
                         v
              +----------------------+
              |       Jump Host      |
              |        thor          |
              +----------+-----------+
                         |
                         | HTTP :8093
                         v
              +----------------------+
              |      stapp02         |
              |   Nginx Web Server   |
              |       :8093          |
              +----------+-----------+
                         |
                         | FastCGI
                         v
              +----------------------+
              |      PHP-FPM 8.2     |
              |                      |
              | /var/run/php-fpm/    |
              |    default.sock      |
              +----------+-----------+
                         |
                         v
              +----------------------+
              |   /var/www/html/     |
              |                      |
              |    index.php         |
              |    info.php          |
              +----------------------+
```

---

# 📋 Infrastructure Details

| Server | Hostname | User | Purpose |
|---|---|---|---|
| Application Server 1 | `stapp01` | `tony` | Nautilus Application 1 |
| Application Server 2 | `stapp02` | `steve` | Nautilus Application 2 |
| Application Server 3 | `stapp03` | `banner` | Nautilus Application 3 |
| Load Balancer | `stlb01` | `loki` | HTTP Load Balancer |
| Database Server | `stdb01` | `peter` | Database |
| Jump Host | `jump-host` | `thor` | Secure access to infrastructure |

---

# 🎯 Task Requirements

### Application Server 2

1. Install Nginx.
2. Configure Nginx to listen on port `8093`.
3. Configure document root as `/var/www/html`.
4. Install PHP-FPM version `8.2`.
5. Configure PHP-FPM to use:

```text
/var/run/php-fpm/default.sock
```

6. Configure Nginx and PHP-FPM to work together.
7. Do not modify the existing:

```text
/var/www/html/index.php
/var/www/html/info.php
```

8. Verify the application from the Jump Host:

```bash
curl http://stapp02:8093/index.php
```

---

# 1. Connect to App Server 2

From the Jump Host:

```bash
ssh steve@stapp02
```

---

# 2. Verify Existing PHP Application

Check the application files:

```bash
ls -l /var/www/html/
```

Expected:

```text
index.php
info.php
```

**Important:** Do not modify these files.

---

# 3. Install Nginx

Check package availability:

```bash
dnf list available nginx
```

Install Nginx:

```bash
sudo dnf install -y nginx
```

Verify:

```bash
nginx -v
```

Enable and start Nginx:

```bash
sudo systemctl enable --now nginx
```

Verify:

```bash
sudo systemctl status nginx
```

---

# 4. Install PHP-FPM 8.2

Check available PHP streams:

```bash
sudo dnf module list php
```

Enable PHP 8.2:

```bash
sudo dnf module enable php:8.2 -y
```

Install PHP-FPM:

```bash
sudo dnf install -y php-fpm php-cli
```

Verify PHP version:

```bash
php -v
```

Verify PHP-FPM:

```bash
php-fpm -v
```

Expected:

```text
PHP 8.2.x
```

---

# 5. Configure PHP-FPM Unix Socket

Create the required directory:

```bash
sudo mkdir -p /var/run/php-fpm
```

Edit:

```bash
sudo vi /etc/php-fpm.d/www.conf
```

Configure:

```ini
user = apache
group = apache

listen = /var/run/php-fpm/default.sock

listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

### Important

If the following line exists:

```ini
listen.acl_users = apache,nginx
```

comment it out:

```ini
;listen.acl_users = apache,nginx
```

For this configuration, we want PHP-FPM to use:

```ini
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

instead of relying on ACL-based socket access.

---

# 6. Validate PHP-FPM Configuration

Run:

```bash
sudo php-fpm -t
```

Expected:

```text
configuration file ... test is successful
```

You can also inspect the effective configuration:

```bash
sudo php-fpm -tt 2>&1 | grep -E 'user|group|listen|listen.owner|listen.group|listen.mode'
```

Expected:

```text
user = apache
group = apache
listen = /var/run/php-fpm/default.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

---

# 7. Start PHP-FPM

Enable and start:

```bash
sudo systemctl enable --now php-fpm
```

Check:

```bash
sudo systemctl status php-fpm
```

Verify the socket:

```bash
sudo ls -l /var/run/php-fpm/default.sock
```

Expected:

```text
srw-rw---- 1 nginx nginx ... default.sock
```

---

# 8. Configure Nginx

Create a dedicated configuration:

```bash
sudo vi /etc/nginx/conf.d/php.conf
```

Add:

```nginx
server {
    listen 8093;
    server_name stapp02;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include /etc/nginx/fastcgi_params;

        fastcgi_pass unix:/var/run/php-fpm/default.sock;
        fastcgi_index index.php;

        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }
}
```

---

# 9. Understand the Nginx Configuration

### Listen on port 8093

```nginx
listen 8093;
```

Nginx accepts HTTP requests on port `8093`.

### Document Root

```nginx
root /var/www/html;
```

PHP application files are located here.

### Default PHP file

```nginx
index index.php index.html;
```

Nginx can use `index.php` as the default application page.

### PHP Location Block

```nginx
location ~ \.php$ {
```

This matches PHP requests.

### PHP-FPM Unix Socket

```nginx
fastcgi_pass unix:/var/run/php-fpm/default.sock;
```

This is the most important part.

Nginx forwards PHP requests to PHP-FPM through the Unix socket.

### PHP Script Path

```nginx
fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
```

This tells PHP-FPM which PHP file needs to be executed.

---

# 10. Validate Nginx Configuration

Run:

```bash
sudo nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

Restart Nginx:

```bash
sudo systemctl restart nginx
```

Check:

```bash
sudo systemctl status nginx
```

---

# 11. Verify Nginx Port

Check that Nginx is listening on `8093`:

```bash
sudo ss -lntp | grep 8093
```

If `ss` is not installed:

```bash
sudo dnf install -y iproute
```

Then:

```bash
sudo ss -lntp | grep 8093
```

Expected:

```text
LISTEN ... :8093 ... nginx
```

---

# 12. Test PHP Locally

From `stapp02`:

```bash
curl -i http://localhost:8093/index.php
```

Test the PHP information page:

```bash
curl -i http://localhost:8093/info.php
```

PHP should be executed by PHP-FPM.

You should **not** see the PHP source code.

---

# 13. Test From Jump Host

Exit App Server 2:

```bash
exit
```

From the Jump Host:

```bash
curl http://stapp02:8093/index.php
```

Also test:

```bash
curl http://stapp02:8093/info.php
```

---

# 🔍 Troubleshooting

## Issue 1: PHP-FPM socket shows `root:root`

Example:

```text
srw-rw----+ 1 root root ... default.sock
```

Check ACL:

```bash
sudo getfacl /var/run/php-fpm/default.sock
```

If you see:

```text
user:nginx:rw-
```

then Nginx has explicit access through ACL.

However, if the intended configuration is to have the socket owned by Nginx, check:

```bash
sudo grep -E '^(listen|listen.owner|listen.group|listen.mode|listen.acl)' /etc/php-fpm.d/www.conf
```

Make sure:

```ini
listen = /var/run/php-fpm/default.sock
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

If present, remove/comment:

```ini
;listen.acl_users = apache,nginx
```

Restart PHP-FPM:

```bash
sudo systemctl restart php-fpm
```

Then verify:

```bash
sudo ls -l /var/run/php-fpm/default.sock
```

---

# 🔍 Troubleshooting Commands

### PHP-FPM status

```bash
sudo systemctl status php-fpm
```

### PHP-FPM configuration test

```bash
sudo php-fpm -t
```

### Effective PHP-FPM configuration

```bash
sudo php-fpm -tt
```

### Nginx configuration test

```bash
sudo nginx -t
```

### Nginx status

```bash
sudo systemctl status nginx
```

### Check Nginx listening port

```bash
sudo ss -lntp | grep 8093
```

### Check PHP-FPM socket

```bash
sudo ls -l /var/run/php-fpm/default.sock
```

### Check socket ACL

```bash
sudo getfacl /var/run/php-fpm/default.sock
```

### Check Nginx errors

```bash
sudo tail -50 /var/log/nginx/error.log
```

### Check PHP-FPM logs

```bash
sudo journalctl -u php-fpm -n 50 --no-pager
```

---

# 🚨 Common Errors

## 502 Bad Gateway

Usually means Nginx cannot communicate with PHP-FPM.

Check:

```bash
sudo systemctl status php-fpm
```

Check socket:

```bash
sudo ls -l /var/run/php-fpm/default.sock
```

Check Nginx configuration:

```bash
sudo nginx -t
```

Check:

```bash
sudo tail -50 /var/log/nginx/error.log
```

---

## PHP Source Code Appears in Browser/Curl

Example:

```php
<?php
echo "Hello";
?>
```

This means Nginx is not forwarding PHP requests to PHP-FPM.

Verify:

```nginx
location ~ \.php$ {
    include /etc/nginx/fastcgi_params;
    fastcgi_pass unix:/var/run/php-fpm/default.sock;
    fastcgi_index index.php;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
}
```

---

## 404 Not Found

Check:

```bash
ls -l /var/www/html/
```

Verify:

```text
index.php
info.php
```

Also verify:

```nginx
root /var/www/html;
```

---

## Nginx Not Listening on 8093

Check:

```bash
sudo nginx -t
```

Then:

```bash
sudo ss -lntp | grep 8093
```

Search all Nginx configurations:

```bash
sudo grep -R "listen" /etc/nginx/
```

Make sure the required server block contains:

```nginx
listen 8093;
```

---

# 🧠 What This Lab Teaches

This lab demonstrates a common production architecture:

```text
Browser / Client
       |
       | HTTP
       v
     Nginx
       |
       | FastCGI
       v
   PHP-FPM
       |
       | Unix Socket
       v
 PHP Application
```

### Nginx

Nginx handles:

- HTTP connections
- Static content
- Port `8093`
- Request routing
- Forwarding PHP requests

### PHP-FPM

PHP-FPM handles:

- PHP process management
- Executing PHP code
- Returning PHP output

### Unix Socket

The socket:

```text
/var/run/php-fpm/default.sock
```

provides local communication between Nginx and PHP-FPM.

---

# 🔄 Request Flow

When a user runs:

```bash
curl http://stapp02:8093/index.php
```

the request follows this path:

```text
curl
 |
 | HTTP :8093
 v
Nginx
 |
 | Detects .php
 |
 | FastCGI
 v
/var/run/php-fpm/default.sock
 |
 v
PHP-FPM
 |
 | Executes
 v
/var/www/html/index.php
 |
 v
PHP-FPM
 |
 v
Nginx
 |
 v
curl
```

---

# ✅ Final Validation Checklist

- [ ] Nginx installed
- [ ] Nginx running
- [ ] Nginx configured for port `8093`
- [ ] Document root configured as `/var/www/html`
- [ ] PHP 8.2 installed
- [ ] PHP-FPM running
- [ ] PHP-FPM socket configured as `/var/run/php-fpm/default.sock`
- [ ] `listen.owner = nginx`
- [ ] `listen.group = nginx`
- [ ] `listen.mode = 0660`
- [ ] Nginx configured to use the PHP-FPM Unix socket
- [ ] `nginx -t` successful
- [ ] `php-fpm -t` successful
- [ ] `index.php` works locally
- [ ] `info.php` works locally
- [ ] `curl http://stapp02:8093/index.php` works from Jump Host
- [ ] Existing PHP files were not modified

---

# 🎯 Key DevOps Takeaway

The important lesson is not simply:

> "Install Nginx and PHP-FPM."

The real lesson is understanding how two services communicate:

```text
Nginx
  |
  | FastCGI
  v
Unix Socket
  |
  v
PHP-FPM
  |
  v
PHP Application
```

When troubleshooting this type of application, isolate each layer:

```text
1. Is PHP 8.2 installed?
        ↓
2. Is PHP-FPM running?
        ↓
3. Does the Unix socket exist?
        ↓
4. Can Nginx access the socket?
        ↓
5. Is Nginx listening on 8093?
        ↓
6. Is Nginx forwarding .php requests?
        ↓
7. Does curl return the PHP application's response?
```

This layered troubleshooting approach is much more valuable in real DevOps work than simply memorizing installation commands.

---

## 📚 References

The KodeKloud community has several recent examples of this same Nginx + PHP-FPM Unix-socket task, including verification of the socket, Nginx configuration, and local/Jump Host testing.

**Lab:** Nautilus / Stratos Datacenter — Configure Nginx + PHP-FPM Using Unix Socket.