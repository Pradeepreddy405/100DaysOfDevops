# Nginx HTTPS SSL Configuration on App Server 2

## 📌 Task Overview

The system administrators of **xFusionCorp Industries** required **App Server 2** in the **Stratos Datacenter** to be prepared for application deployment.

The requirements were:

- Install and configure Nginx.
- Configure the provided self-signed SSL certificate and private key.
- Create an `index.html` page containing `Welcome!`.
- Enable HTTPS access through Nginx.
- Verify the application from the Jump Host using `curl`.

---

## 🏗️ Environment

| Component | Details |
|---|---|
| Server | App Server 2 |
| Hostname | `stapp02` |
| Web Server | Nginx |
| HTTP Port | `80` |
| HTTPS Port | `443` |
| Document Root | `/usr/share/nginx/html` |
| SSL Certificate | `/etc/nginx/ssl/nautilus.crt` |
| SSL Private Key | `/etc/nginx/ssl/nautilus.key` |

---

# 1. Connect to App Server 2

From the Jump Host:

```bash
ssh stapp02
```

---

# 2. Install Nginx

Install the Nginx package:

```bash
sudo dnf install -y nginx
```

Enable Nginx to start automatically after reboot:

```bash
sudo systemctl enable nginx
```

Start the service:

```bash
sudo systemctl start nginx
```

Or enable and start it in one command:

```bash
sudo systemctl enable --now nginx
```

Verify:

```bash
sudo systemctl status nginx
```

Expected:

```text
Active: active (running)
```

---

# 3. Prepare SSL Certificate and Key

The SSL files were already available under `/tmp`:

```text
/tmp/nautilus.crt
/tmp/nautilus.key
```

Create a dedicated SSL directory:

```bash
sudo mkdir -p /etc/nginx/ssl
```

Move the certificate:

```bash
sudo mv /tmp/nautilus.crt /etc/nginx/ssl/
```

Move the private key:

```bash
sudo mv /tmp/nautilus.key /etc/nginx/ssl/
```

Verify:

```bash
sudo ls -l /etc/nginx/ssl/
```

Expected files:

```text
nautilus.crt
nautilus.key
```

Set appropriate permissions:

```bash
sudo chmod 644 /etc/nginx/ssl/nautilus.crt
sudo chmod 600 /etc/nginx/ssl/nautilus.key
```

The private key should not be world-readable.

---

# 4. Create the Website

Nginx's document root is:

```text
/usr/share/nginx/html
```

Create the required `index.html`:

```bash
echo "Welcome!" | sudo tee /usr/share/nginx/html/index.html
```

Verify:

```bash
cat /usr/share/nginx/html/index.html
```

Expected:

```text
Welcome!
```

---

# 5. Configure Nginx for HTTPS

Create a dedicated Nginx server configuration:

```bash
sudo vi /etc/nginx/conf.d/nautilus.conf
```

Add:

```nginx
server {
    listen 80;
    server_name stapp02;

    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name stapp02;

    root /usr/share/nginx/html;
    index index.html;

    ssl_certificate /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key /etc/nginx/ssl/nautilus.key;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Configuration Explanation

#### HTTP

```nginx
listen 80;
```

Nginx listens for normal HTTP traffic.

```nginx
return 301 https://$host$request_uri;
```

HTTP requests are redirected to HTTPS.

#### HTTPS

```nginx
listen 443 ssl;
```

Nginx listens for HTTPS traffic on port `443`.

```nginx
ssl_certificate /etc/nginx/ssl/nautilus.crt;
```

Specifies the SSL certificate.

```nginx
ssl_certificate_key /etc/nginx/ssl/nautilus.key;
```

Specifies the private key.

```nginx
root /usr/share/nginx/html;
```

Defines the website document root.

---

# 6. Validate Nginx Configuration

Before restarting Nginx, always test the configuration:

```bash
sudo nginx -t
```

Expected:

```text
syntax is ok
test is successful
```

This prevents restarting Nginx with a broken configuration.

---

# 7. Restart Nginx

```bash
sudo systemctl restart nginx
```

Verify:

```bash
sudo systemctl status nginx --no-pager
```

---

# 8. Verify Listening Ports

Check whether Nginx is listening on HTTP and HTTPS:

```bash
sudo ss -lntp | grep nginx
```

Expected ports:

```text
:80
:443
```

---

# 9. Test HTTPS Locally

Because the certificate is self-signed, normal `curl` certificate validation will fail.

Use:

```bash
curl -k https://stapp02/
```

Expected output:

```text
Welcome!
```

The `-k` option tells `curl` to allow an untrusted/self-signed certificate.

Check only the response headers:

```bash
curl -k -I https://stapp02/
```

Expected:

```text
HTTP/1.1 200 OK
Server: nginx
```

---

# 10. Final Verification from Jump Host

Exit App Server 2:

```bash
exit
```

From the Jump Host:

```bash
curl -k https://stapp02/
```

Expected:

```text
Welcome!
```

Check HTTPS response headers:

```bash
curl -k -I https://stapp02/
```

Expected:

```text
HTTP/1.1 200 OK
Server: nginx
```

---

# 🔍 Troubleshooting Commands

### Check Nginx service

```bash
sudo systemctl status nginx
```

### Test configuration

```bash
sudo nginx -t
```

### Check listening ports

```bash
sudo ss -lntp | grep -E ':80|:443'
```

### Check Nginx error logs

```bash
sudo tail -f /var/log/nginx/error.log
```

### Check access logs

```bash
sudo tail -f /var/log/nginx/access.log
```

### Check SSL files

```bash
sudo ls -l /etc/nginx/ssl/
```

### Verify certificate

```bash
openssl x509 -in /etc/nginx/ssl/nautilus.crt -text -noout
```

### Test HTTPS

```bash
curl -k -I https://stapp02/
```

---

# 🧠 Key DevOps Concepts Learned

- Installing and managing Nginx on Linux
- Managing Linux services with `systemctl`
- Nginx server blocks
- HTTP vs HTTPS
- SSL/TLS certificate configuration
- Private key permissions
- Nginx document root
- HTTP → HTTPS redirection
- Nginx configuration validation
- Checking listening ports with `ss`
- Testing web services with `curl`
- Working with self-signed certificates
- Basic Nginx troubleshooting using logs

---

# ✅ Final Checklist

- [x] Nginx installed
- [x] Nginx enabled and running
- [x] SSL certificate moved to `/etc/nginx/ssl/`
- [x] SSL private key moved to `/etc/nginx/ssl/`
- [x] Private key permissions secured
- [x] `index.html` created
- [x] `Welcome!` configured
- [x] HTTPS configured on port `443`
- [x] HTTP configured to redirect to HTTPS
- [x] Nginx configuration validated
- [x] HTTPS tested with `curl`
- [x] Final verification performed from Jump Host

---

## 🎯 Result

Nginx was successfully installed and configured on **App Server 2** with the provided self-signed SSL certificate and private key.

The application is accessible through:

```text
https://stapp02/
```

Final verification:

```bash
curl -k https://stapp02/
```

Output:

```text
Welcome!
```